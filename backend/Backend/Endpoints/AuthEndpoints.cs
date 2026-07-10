using System.Security.Claims;
using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Models;
using Backend.Services;
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
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return Results.BadRequest(new { message = "Email과 Password는 필수입니다." });

            if (request.Password.Length < 6)
                return Results.BadRequest(new { message = "Password는 6자 이상이어야 합니다." });

            var email = request.Email.Trim().ToLowerInvariant();

            if (await db.Users.AnyAsync(u => u.Email == email))
                return Results.Conflict(new { message = "이미 가입된 이메일입니다." });

            var user = new User { Email = email };
            user.PasswordHash = hasher.HashPassword(user, request.Password);

            db.Users.Add(user);
            await db.SaveChangesAsync();

            return Results.Created($"/auth/me", new UserResponse(user.Id, user.Email, user.CreatedAt));
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

            if (user is null)
                return Results.Unauthorized();

            var result = hasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
            if (result == PasswordVerificationResult.Failed)
                return Results.Unauthorized();

            var accessToken = tokenService.CreateAccessToken(user, out var expiresAt);
            var rawRefreshToken = tokenService.CreateRefreshTokenValue();

            db.RefreshTokens.Add(new RefreshToken
            {
                UserId = user.Id,
                TokenHash = tokenService.HashRefreshToken(rawRefreshToken),
                ExpiresAt = DateTime.UtcNow.AddDays(7),
            });
            await db.SaveChangesAsync();

            return Results.Ok(new AuthResponse(accessToken, rawRefreshToken, expiresAt));
        })
            .WithName("Login");

        group.MapPost("/refresh", async (
            RefreshRequest request,
            AppDbContext db,
            ITokenService tokenService) =>
        {
            var hash = tokenService.HashRefreshToken(request.RefreshToken);
            var existing = await db.RefreshTokens
                .Include(rt => rt.User)
                .FirstOrDefaultAsync(rt => rt.TokenHash == hash);

            if (existing is null || !existing.IsActive)
                return Results.Unauthorized();

            // 토큰 회전: 기존 refresh token은 폐기하고 새로 발급
            existing.RevokedAt = DateTime.UtcNow;

            var accessToken = tokenService.CreateAccessToken(existing.User, out var expiresAt);
            var rawRefreshToken = tokenService.CreateRefreshTokenValue();

            db.RefreshTokens.Add(new RefreshToken
            {
                UserId = existing.UserId,
                TokenHash = tokenService.HashRefreshToken(rawRefreshToken),
                ExpiresAt = DateTime.UtcNow.AddDays(7),
            });
            await db.SaveChangesAsync();

            return Results.Ok(new AuthResponse(accessToken, rawRefreshToken, expiresAt));
        })
            .WithName("Refresh");

        group.MapPost("/logout", async (
            LogoutRequest request,
            AppDbContext db,
            ITokenService tokenService) =>
        {
            var hash = tokenService.HashRefreshToken(request.RefreshToken);
            var existing = await db.RefreshTokens.FirstOrDefaultAsync(rt => rt.TokenHash == hash);

            if (existing is not null && existing.RevokedAt is null)
            {
                existing.RevokedAt = DateTime.UtcNow;
                await db.SaveChangesAsync();
            }

            return Results.NoContent();
        })
            .WithName("Logout");

        group.MapGet("/me", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var user = await db.Users.FindAsync(userId);
            return user is null
                ? Results.NotFound()
                : Results.Ok(new UserResponse(user.Id, user.Email, user.CreatedAt));
        })
            .RequireAuthorization()
            .WithName("Me");
    }
}
