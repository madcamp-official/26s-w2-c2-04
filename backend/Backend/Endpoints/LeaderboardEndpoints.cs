using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class LeaderboardEndpoints
{
    private const int PageSize = 100;
    private const int MaxPage = 1_000_000; // (page-1)*PageSize가 int 오버플로로 음수 OFFSET이 되는 것을 방지

    public static void MapLeaderboardEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/leaderboard").RequireAuthorization();

        group.MapGet("/{playerCount:int}", async (int playerCount, int? page, HttpContext http, AppDbContext db) =>
        {
            if (playerCount is < 2 or > 4)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "playerCount는 2~4여야 합니다." });

            var pageNum = page is > 0 ? Math.Min(page.Value, MaxPage) : 1;
            var userId = http.User.GetUserId();

            var query = db.PlayerRankings
                .Include(pr => pr.User)
                .Where(pr => pr.PlayerCount == playerCount)
                .OrderByDescending(pr => pr.Mmr)
                .ThenByDescending(pr => pr.GamesPlayed)
                .ThenBy(pr => pr.Id);

            var total = await query.CountAsync();
            var pageRankings = await query.Skip((pageNum - 1) * PageSize).Take(PageSize).ToListAsync();

            var entries = pageRankings
                .Select((pr, i) => ToEntry(pr, (pageNum - 1) * PageSize + i + 1))
                .ToList();

            var myRanking = await db.PlayerRankings
                .Include(pr => pr.User)
                .FirstOrDefaultAsync(pr => pr.PlayerCount == playerCount && pr.UserId == userId);
            LeaderboardEntryResponse? myRank = null;
            if (myRanking is not null)
            {
                var rank = await ComputeRankAsync(db, playerCount, myRanking.Mmr, myRanking.GamesPlayed, myRanking.Id);
                myRank = ToEntry(myRanking, rank);
            }

            return Results.Ok(new LeaderboardResponse(playerCount, pageNum, PageSize, total, entries, myRank));
        })
            .WithName("GetLeaderboard");

        group.MapGet("/{playerCount:int}/search", async (int playerCount, string? query, AppDbContext db) =>
        {
            if (playerCount is < 2 or > 4)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "playerCount는 2~4여야 합니다." });

            var searchTerm = query ?? string.Empty;
            var searchUserId = int.TryParse(searchTerm, out var parsedId) ? parsedId : (int?)null;
            var likePattern = $"%{EscapeLikePattern(searchTerm)}%";

            var matches = await db.PlayerRankings
                .Include(pr => pr.User)
                .Where(pr => pr.PlayerCount == playerCount
                    && (EF.Functions.Like(pr.User.Nickname, likePattern, "\\") || pr.UserId == searchUserId))
                .OrderByDescending(pr => pr.Mmr)
                .ThenByDescending(pr => pr.GamesPlayed)
                .ThenBy(pr => pr.Id)
                .Take(PageSize)
                .ToListAsync();

            var entries = new List<LeaderboardEntryResponse>();
            foreach (var match in matches)
            {
                var rank = await ComputeRankAsync(db, playerCount, match.Mmr, match.GamesPlayed, match.Id);
                entries.Add(ToEntry(match, rank));
            }

            return Results.Ok(new LeaderboardSearchResponse(playerCount, searchTerm, entries.Count, entries));
        })
            .WithName("SearchLeaderboard");
    }

    /// <summary>LIKE 패턴의 %, _, \ 를 리터럴로 이스케이프한다(닉네임에 이런 문자가 들어있어도 와일드카드로 해석되지 않게).</summary>
    internal static string EscapeLikePattern(string term) =>
        term.Replace("\\", "\\\\").Replace("%", "\\%").Replace("_", "\\_");

    internal static async Task<int> ComputeRankAsync(AppDbContext db, int playerCount, int mmr, int gamesPlayed, int id) =>
        1 + await db.PlayerRankings.CountAsync(pr =>
            pr.PlayerCount == playerCount &&
            (pr.Mmr > mmr
                || (pr.Mmr == mmr && pr.GamesPlayed > gamesPlayed)
                || (pr.Mmr == mmr && pr.GamesPlayed == gamesPlayed && pr.Id < id)));

    private static LeaderboardEntryResponse ToEntry(PlayerRanking ranking, int rank) => new(
        rank,
        ranking.UserId,
        ranking.User.Nickname,
        ranking.User.AvatarUrl,
        ranking.Mmr,
        Math.Round(ranking.AvgPlace, 2),
        ranking.GamesPlayed);
}
