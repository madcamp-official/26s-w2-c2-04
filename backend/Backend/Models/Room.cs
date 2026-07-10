namespace Backend.Models;

public enum RoomStatus
{
    Waiting,
    Playing,
}

public enum RoomRuleset
{
    Official,
    Casual,
}

public class Room
{
    public int Id { get; set; }
    public int HostId { get; set; }
    public User Host { get; set; } = null!;
    public RoomStatus Status { get; set; } = RoomStatus.Waiting;
    public int MaxPlayers { get; set; } = 4;
    public bool IsPrivate { get; set; }
    public string? Password { get; set; }
    public RoomRuleset Ruleset { get; set; } = RoomRuleset.Official;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<RoomPlayer> Players { get; set; } = new();
}
