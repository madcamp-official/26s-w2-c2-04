using System.Security.Claims;
using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class ProfileEndpoints
{
    private const int RecentMatchLimit = 10;
    private const long MaxAvatarBytes = 2 * 1024 * 1024;
    private static readonly string[] AllowedContentTypes = ["image/png", "image/jpeg", "image/webp"];

    public static void MapProfileEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/profile").RequireAuthorization();

        group.MapGet("/me", async (ClaimsPrincipal principal, AppDbContext db) =>
            await BuildProfileAsync(db, principal.GetUserId()))
            .WithName("GetMyProfile");

        group.MapGet("/{userId:int}", async (int userId, AppDbContext db) =>
            await BuildProfileAsync(db, userId))
            .WithName("GetProfile");

        group.MapPost("/avatar", async (IFormFile file, ClaimsPrincipal principal, AppDbContext db) =>
        {
            if (!AllowedContentTypes.Contains(file.ContentType))
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "png, jpeg, webp 이미지만 업로드할 수 있습니다." });

            if (file.Length == 0 || file.Length > MaxAvatarBytes)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "이미지 크기는 2MB를 초과할 수 없습니다." });

            var userId = principal.GetUserId();
            var user = await db.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user is null)
                return Results.NotFound();

            using var stream = new MemoryStream();
            await file.CopyToAsync(stream);
            var bytes = stream.ToArray();

            if (!HasValidImageSignature(bytes, file.ContentType))
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "파일 내용이 선언된 이미지 형식과 일치하지 않습니다." });

            user.AvatarImage = bytes;
            user.AvatarContentType = file.ContentType;
            await db.SaveChangesAsync();

            return await BuildProfileAsync(db, userId);
        })
            .DisableAntiforgery()
            .WithName("UploadAvatar");

        group.MapDelete("/avatar", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var user = await db.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user is null)
                return Results.NotFound();

            user.AvatarImage = null;
            user.AvatarContentType = null;
            await db.SaveChangesAsync();

            return Results.NoContent();
        })
            .WithName("DeleteAvatar");

        group.MapGet("/{userId:int}/avatar", async (int userId, AppDbContext db) =>
        {
            var user = await db.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user?.AvatarImage is null || user.AvatarContentType is null)
                return Results.NotFound();

            return Results.File(user.AvatarImage, user.AvatarContentType);
        })
            .WithName("GetAvatar");
    }

    /// <summary>업로드된 바이트가 실제로 선언한 이미지 형식의 매직 넘버로 시작하는지 확인한다(Content-Type 헤더는 클라이언트가 조작 가능).</summary>
    private static bool HasValidImageSignature(byte[] bytes, string contentType) => contentType switch
    {
        "image/png" => bytes.Length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47,
        "image/jpeg" => bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF,
        "image/webp" => bytes.Length >= 12
            && bytes[0] == 'R' && bytes[1] == 'I' && bytes[2] == 'F' && bytes[3] == 'F'
            && bytes[8] == 'W' && bytes[9] == 'E' && bytes[10] == 'B' && bytes[11] == 'P',
        _ => false,
    };

    private static async Task<IResult> BuildProfileAsync(AppDbContext db, int userId)
    {
        var user = await db.Users
            .Where(u => u.Id == userId)
            .Select(u => new { u.Id, u.Nickname, HasAvatar = u.AvatarImage != null })
            .FirstOrDefaultAsync();
        if (user is null)
            return Results.NotFound();
        var avatarUrl = user.HasAvatar ? $"/profile/{user.Id}/avatar" : null;

        var rankings = await db.PlayerRankings
            .Where(pr => pr.UserId == userId)
            .OrderBy(pr => pr.PlayerCount)
            .ToListAsync();

        var rankingSummaries = new List<RankingSummaryResponse>();
        foreach (var ranking in rankings)
        {
            var rank = await LeaderboardEndpoints.ComputeRankAsync(db, ranking.PlayerCount, ranking.Mmr, ranking.GamesPlayed, ranking.Id);
            rankingSummaries.Add(new RankingSummaryResponse(ranking.PlayerCount, rank, ranking.Mmr, ranking.GamesPlayed, Math.Round(ranking.AvgPlace, 2)));
        }

        var totalGamesPlayed = rankings.Sum(pr => pr.GamesPlayed);
        var totalPlaceSum = rankings.Sum(pr => pr.TotalPlaceSum);
        var overallAvgPlace = totalGamesPlayed == 0 ? 0 : Math.Round((double)totalPlaceSum / totalGamesPlayed, 2);

        var recentMatches = await db.GamePlayerResults
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAt)
            .Take(RecentMatchLimit)
            .Select(r => new RecentMatchResponse(r.GameId, r.PlayerCount, r.Place, r.Score, r.IsRanked, r.CreatedAt))
            .ToListAsync();

        return Results.Ok(new ProfileResponse(
            user.Id, user.Nickname, avatarUrl, totalGamesPlayed, overallAvgPlace, rankingSummaries, recentMatches));
    }
}
