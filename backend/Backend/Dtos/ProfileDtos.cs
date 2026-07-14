namespace Backend.Dtos;

public record RankingSummaryResponse(
    int PlayerCount,
    int Rank,
    int Mmr,
    int GamesPlayed,
    double AvgPlace);

public record RecentMatchResponse(
    int GameId,
    int PlayerCount,
    int Place,
    int Score,
    bool IsRanked,
    DateTime PlayedAt);

public record ProfileResponse(
    int UserId,
    string Nickname,
    string? AvatarUrl,
    int TotalGamesPlayed,
    double OverallAvgPlace,
    List<RankingSummaryResponse> Rankings,
    List<RecentMatchResponse> RecentMatches);
