using System.Security.Claims;
using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Hubs;
using Backend.Models;
using Backend.Services;
using Backend.Services.OAuth;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class AuthEndpoints
{
    private const int NicknameMaxLength = 20;
    private static readonly TimeSpan StaleRefreshTokenAge = TimeSpan.FromDays(30);

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

            if (request.Nickname.Trim().Length > NicknameMaxLength)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = $"nickname은 {NicknameMaxLength}자를 초과할 수 없습니다." });

            var email = request.Email.Trim().ToLowerInvariant();
            if (await db.Users.AnyAsync(u => u.Email == email))
                return Results.Conflict(new { code = "EMAIL_ALREADY_EXISTS", message = "이미 가입된 이메일입니다." });

            var user = new User { Email = email, Nickname = request.Nickname.Trim() };
            user.PasswordHash = hasher.HashPassword(user, request.Password);

            db.Users.Add(user);
            try
            {
                await db.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                // 동시에 같은 이메일로 가입 요청이 들어와 유니크 제약에 걸린 경우.
                return Results.Conflict(new { code = "EMAIL_ALREADY_EXISTS", message = "이미 가입된 이메일입니다." });
            }

            var response = await IssueEmailAuthAsync(user, db, tokenService);
            return Results.Created("/auth/me", response);
        })
            .WithName("Register");

        group.MapPost("/login", async (
            LoginRequest request,
            AppDbContext db,
            IPasswordHasher<User> hasher,
            ITokenService tokenService,
            PresenceStore presence) =>
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "email, password는 필수입니다." });

            var email = request.Email.Trim().ToLowerInvariant();
            var user = await db.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user?.PasswordHash is null)
                return Results.Unauthorized();

            if (hasher.VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
                return Results.Unauthorized();

            if (await presence.IsSocialOnlineAsync(user.Id))
                return Results.Conflict(new { code = "ALREADY_LOGGED_IN", message = "이미 다른 기기/브라우저에서 로그인 중입니다." });

            var response = await IssueEmailAuthAsync(user, db, tokenService);
            return Results.Ok(response);
        })
            .WithName("Login");

        group.MapPost("/oauth/kakao", (KakaoOAuthRequest request, AppDbContext db, OAuthProviderResolver resolver, ITokenService tokenService, PresenceStore presence) =>
            HandleOAuthLoginAsync(resolver.Resolve("kakao")!, request.KakaoAccessToken, db, tokenService, presence))
            .WithName("OAuthKakao");

        group.MapPost("/oauth/naver", (NaverOAuthRequest request, AppDbContext db, OAuthProviderResolver resolver, ITokenService tokenService, PresenceStore presence) =>
            HandleOAuthLoginAsync(resolver.Resolve("naver")!, request.NaverAccessToken, db, tokenService, presence))
            .WithName("OAuthNaver");

        group.MapPost("/oauth/google", (GoogleOAuthRequest request, AppDbContext db, OAuthProviderResolver resolver, ITokenService tokenService, PresenceStore presence) =>
            HandleOAuthLoginAsync(resolver.Resolve("google")!, request.IdToken, db, tokenService, presence))
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
                try
                {
                    await db.SaveChangesAsync();
                }
                catch (DbUpdateException)
                {
                    // 동시에 같은 소셜 계정을 다른 유저가 먼저 연동한 경우.
                    return Results.Conflict(new { code = "ALREADY_LINKED", message = "이미 다른 계정에 연동된 소셜 계정입니다." });
                }
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

            if (existing is null)
                return Results.Unauthorized();

            if (existing.RevokedAt is not null)
            {
                // 이미 한 번 회전(rotation)되어 폐기된 토큰이 다시 제시됨 = 탈취 의심.
                // 이 유저의 살아있는 refresh token을 전부 강제 폐기한다.
                var activeTokens = await db.RefreshTokens
                    .Where(rt => rt.UserId == existing.UserId && rt.RevokedAt == null)
                    .ToListAsync();
                foreach (var token in activeTokens)
                    token.RevokedAt = DateTime.UtcNow;
                await db.SaveChangesAsync();
                return Results.Unauthorized();
            }

            if (existing.ExpiresAt <= DateTime.UtcNow)
                return Results.Unauthorized();

            existing.RevokedAt = DateTime.UtcNow;
            var (accessToken, refreshToken, expiresIn) = await IssueTokensAsync(existing.User, db, tokenService);
            return Results.Ok(new RefreshResponse(accessToken, refreshToken, expiresIn));
        })
            .WithName("Refresh");

        group.MapPost("/logout", async (
            ClaimsPrincipal principal, AppDbContext db, GameStateStore stateStore, PresenceStore presence,
            IHubContext<GameHub> hubContext, IHubContext<SocialHub> socialHubContext) =>
        {
            var userId = principal.GetUserId();
            var activeTokens = await db.RefreshTokens
                .Where(rt => rt.UserId == userId && rt.RevokedAt == null)
                .ToListAsync();

            foreach (var token in activeTokens)
                token.RevokedAt = DateTime.UtcNow;
            await db.SaveChangesAsync();

            await RoomDepartureService.HandleUserGoingOfflineAsync(
                db, stateStore, hubContext.Clients, socialHubContext.Clients, presence, userId);

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
        ITokenService tokenService,
        PresenceStore presence)
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
            if (await presence.IsSocialOnlineAsync(user.Id))
                return Results.Conflict(new { code = "ALREADY_LOGGED_IN", message = "이미 다른 기기/브라우저에서 로그인 중입니다." });
        }
        else
        {
            var nickname = string.IsNullOrWhiteSpace(info.Nickname)
                ? $"{oauthProvider.Provider}_{info.ProviderUserId[..Math.Min(6, info.ProviderUserId.Length)]}"
                : info.Nickname;

            user = new User { Email = info.Email, Nickname = nickname };
            // User+ExternalLogin을 한 SaveChangesAsync에 같이 넣어서, 동시에 같은 소셜 계정으로
            // 최초 로그인하는 레이스가 나면 트랜잭션 전체가 롤백되게 한다(User row만 고아로 남는 것 방지).
            user.ExternalLogins.Add(new ExternalLogin { Provider = oauthProvider.Provider, ProviderUserId = info.ProviderUserId });
            db.Users.Add(user);

            try
            {
                await db.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return Results.Json(
                    new { code = "OAUTH_LOGIN_CONFLICT", message = "동시 로그인 요청으로 충돌이 발생했습니다. 다시 시도해주세요." },
                    statusCode: StatusCodes.Status409Conflict);
            }
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

        // 새 토큰을 발급하는 김에, 이 유저 소유의 만료됐거나 폐기된 지 오래된 토큰을 정리한다.
        // 전역 스윕 워커 없이 활성 유저 기준으로 자연스럽게 테이블 크기가 제한된다.
        var staleCutoff = DateTime.UtcNow - StaleRefreshTokenAge;
        var staleTokens = await db.RefreshTokens
            .Where(rt => rt.UserId == user.Id && (rt.ExpiresAt <= DateTime.UtcNow || rt.RevokedAt <= staleCutoff))
            .ToListAsync();
        db.RefreshTokens.RemoveRange(staleTokens);

        await db.SaveChangesAsync();

        return (accessToken, refreshToken, ComputeExpiresIn(expiresAt));
    }

    private static int ComputeExpiresIn(DateTime expiresAt) =>
        (int)Math.Max(0, Math.Round((expiresAt - DateTime.UtcNow).TotalSeconds));
}
