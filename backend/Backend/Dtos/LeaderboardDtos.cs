namespace Backend.Dtos;

public record LeaderboardEntryResponse(
    int Rank,
    int UserId,
    string Nickname,
    string? AvatarUrl,
    int Mmr,
    double AvgPlace,
    int GamesPlayedSeason);

public record LeaderboardResponse(
    int PlayerCount,
    int Page,
    int Limit,
    int Total,
    List<LeaderboardEntryResponse> Entries,
    LeaderboardEntryResponse? MyRank);

public record LeaderboardSearchResponse(
    int PlayerCount,
    string Query,
    int Total,
    List<LeaderboardEntryResponse> Entries);
