using System.Security.Claims;
using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Models;
using Backend.Services;
using Backend.Services.OAuth;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/auth");

        group.MapPost("/register", async (
            RegisterRequest request,
            AppDbContext db,
            IPasswordHasher<User> hasher,
            ITokenService tokenService) =>
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password) || string.IsNullOrWhiteSpace(request.Nickname))
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "email, password, nickname은 필수입니다." });

            if (request.Password.Length < 6)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "password는 6자 이상이어야 합니다." });

            var email = request.Email.Trim().ToLowerInvariant();
            if (await db.Users.AnyAsync(u => u.Email == email))
                return Results.Conflict(new { code = "EMAIL_ALREADY_EXISTS", message = "이미 가입된 이메일입니다." });

            var user = new User { Email = email, Nickname = request.Nickname.Trim() };
            user.PasswordHash = hasher.HashPassword(user, request.Password);

            db.Users.Add(user);
            await db.SaveChangesAsync();

            var response = await IssueEmailAuthAsync(user, db, tokenService);
            return Results.Created("/auth/me", response);
        })
            .WithName("Register");

        group.MapPost("/login", async (
            LoginRequest request,
            AppDbContext db,
            IPasswordHasher<User> hasher,
            ITokenService tokenService) =>
        {
            var email = request.Email.Trim().ToLowerInvariant();
            var user = await db.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user?.PasswordHash is null)
                return Results.Unauthorized();

            if (hasher.VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
                return Results.Unauthorized();

            var response = await IssueEmailAuthAsync(user, db, tokenService);
            return Results.Ok(response);
        })
            .WithName("Login");

        group.MapPost("/oauth/kakao", (KakaoOAuthRequest request, AppDbContext db, OAuthProviderResolver resolver, ITokenService tokenService) =>
            HandleOAuthLoginAsync(resolver.Resolve("kakao")!, request.KakaoAccessToken, db, tokenService))
            .WithName("OAuthKakao");

        group.MapPost("/oauth/naver", (NaverOAuthRequest request, AppDbContext db, OAuthProviderResolver resolver, ITokenService tokenService) =>
            HandleOAuthLoginAsync(resolver.Resolve("naver")!, request.NaverAccessToken, db, tokenService))
            .WithName("OAuthNaver");

        group.MapPost("/oauth/google", (GoogleOAuthRequest request, AppDbContext db, OAuthProviderResolver resolver, ITokenService tokenService) =>
            HandleOAuthLoginAsync(resolver.Resolve("google")!, request.IdToken, db, tokenService))
            .WithName("OAuthGoogle");

        group.MapPost("/link/{provider}", async (
            string provider,
            LinkProviderRequest request,
            ClaimsPrincipal principal,
            AppDbContext db,
            OAuthProviderResolver resolver) =>
        {
            var oauthProvider = resolver.Resolve(provider);
            if (oauthProvider is null)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "지원하지 않는 provider입니다." });

            var info = await oauthProvider.GetUserInfoAsync(request.ProviderToken, CancellationToken.None);
            if (info is null)
                return Results.Json(new { code = "OAUTH_VERIFICATION_FAILED", message = "토큰 검증에 실패했습니다." }, statusCode: StatusCodes.Status401Unauthorized);

            var userId = principal.GetUserId();
            var conflictingLogin = await db.ExternalLogins
                .FirstOrDefaultAsync(e => e.Provider == oauthProvider.Provider && e.ProviderUserId == info.ProviderUserId);

            if (conflictingLogin is not null && conflictingLogin.UserId != userId)
                return Results.Conflict(new { code = "ALREADY_LINKED", message = "이미 다른 계정에 연동된 소셜 계정입니다." });

            if (conflictingLogin is null)
            {
                db.ExternalLogins.Add(new ExternalLogin { UserId = userId, Provider = oauthProvider.Provider, ProviderUserId = info.ProviderUserId });
                await db.SaveChangesAsync();
            }

            var linkedProviders = await db.ExternalLogins
                .Where(e => e.UserId == userId)
                .Select(e => e.Provider.ToString().ToLower())
                .ToListAsync();

            return Results.Ok(new LinkResponse(linkedProviders));
        })
            .RequireAuthorization()
            .WithName("LinkProvider");

        group.MapPost("/refresh", async (RefreshRequest request, AppDbContext db, ITokenService tokenService) =>
        {
            var hash = tokenService.HashRefreshToken(request.RefreshToken);
            var existing = await db.RefreshTokens
                .Include(rt => rt.User)
                .FirstOrDefaultAsync(rt => rt.TokenHash == hash);

            if (existing is null || !existing.IsActive)
                return Results.Unauthorized();

            var accessToken = tokenService.CreateAccessToken(existing.User, out var expiresAt);
            return Results.Ok(new RefreshResponse(accessToken, ComputeExpiresIn(expiresAt)));
        })
            .WithName("Refresh");

        group.MapPost("/logout", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var activeTokens = await db.RefreshTokens
                .Where(rt => rt.UserId == userId && rt.RevokedAt == null)
                .ToListAsync();

            foreach (var token in activeTokens)
                token.RevokedAt = DateTime.UtcNow;

            await RoomEndpoints.LeaveAllWaitingRoomsAsync(db, userId);

            await db.SaveChangesAsync();
            return Results.NoContent();
        })
            .RequireAuthorization()
            .WithName("Logout");

        group.MapGet("/me", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var user = await db.Users.Include(u => u.ExternalLogins).FirstOrDefaultAsync(u => u.Id == userId);
            if (user is null)
                return Results.NotFound();

            var linkedProviders = user.ExternalLogins.Select(e => e.Provider.ToString().ToLower()).ToList();
            return Results.Ok(new MeResponse(user.Id, user.Email, user.Nickname, user.AvatarUrl, linkedProviders, user.CreatedAt));
        })
            .RequireAuthorization()
            .WithName("Me");
    }

    private static async Task<AuthResponse> IssueEmailAuthAsync(User user, AppDbContext db, ITokenService tokenService)
    {
        var (accessToken, refreshToken, expiresIn) = await IssueTokensAsync(user, db, tokenService);
        return new AuthResponse(user.Id, user.Nickname, "email", accessToken, refreshToken, expiresIn);
    }

    private static async Task<IResult> HandleOAuthLoginAsync(
        IOAuthProvider oauthProvider,
        string providerToken,
        AppDbContext db,
        ITokenService tokenService)
    {
        var info = await oauthProvider.GetUserInfoAsync(providerToken, CancellationToken.None);
        if (info is null)
            return Results.Json(new { code = "OAUTH_VERIFICATION_FAILED", message = "토큰 검증에 실패했습니다." }, statusCode: StatusCodes.Status401Unauthorized);

        var existingLogin = await db.ExternalLogins
            .Include(e => e.User)
            .FirstOrDefaultAsync(e => e.Provider == oauthProvider.Provider && e.ProviderUserId == info.ProviderUserId);

        var isNewUser = existingLogin is null;
        User user;
        if (existingLogin is not null)
        {
            user = existingLogin.User;
        }
        else
        {
            var nickname = string.IsNullOrWhiteSpace(info.Nickname)
                ? $"{oauthProvider.Provider}_{info.ProviderUserId[..Math.Min(6, info.ProviderUserId.Length)]}"
                : info.Nickname;

            user = new User { Email = info.Email, Nickname = nickname };
            db.Users.Add(user);
            await db.SaveChangesAsync();

            db.ExternalLogins.Add(new ExternalLogin { UserId = user.Id, Provider = oauthProvider.Provider, ProviderUserId = info.ProviderUserId });
        }

        var (accessToken, refreshToken, expiresIn) = await IssueTokensAsync(user, db, tokenService);
        var providerName = oauthProvider.Provider.ToString().ToLower();
        return Results.Ok(new OAuthAuthResponse(user.Id, user.Nickname, providerName, accessToken, refreshToken, expiresIn, isNewUser));
    }

    private static async Task<(string AccessToken, string RefreshToken, int ExpiresIn)> IssueTokensAsync(
        User user, AppDbContext db, ITokenService tokenService)
    {
        var accessToken = tokenService.CreateAccessToken(user, out var expiresAt);
        var refreshToken = tokenService.CreateRefreshTokenValue();

        db.RefreshTokens.Add(new RefreshToken
        {
            UserId = user.Id,
            TokenHash = tokenService.HashRefreshToken(refreshToken),
            ExpiresAt = DateTime.UtcNow.AddDays(7),
        });
        await db.SaveChangesAsync();

        return (accessToken, refreshToken, ComputeExpiresIn(expiresAt));
    }

    private static int ComputeExpiresIn(DateTime expiresAt) =>
        (int)Math.Max(0, Math.Round((expiresAt - DateTime.UtcNow).TotalSeconds));
}
