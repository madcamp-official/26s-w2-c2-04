namespace Backend.Dtos;

/// <summary>
/// Status: "QUEUED" | "MATCHED" | "NOT_QUEUED".
/// MATCHED일 때만 RoomId가 채워지고, QUEUED일 때만 Mmr/SearchRange가 채워진다.
/// </summary>
public record MatchmakingStatusResponse(string Status, int PlayerCount, int? Mmr, int? SearchRange, int? RoomId);
