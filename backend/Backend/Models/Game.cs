namespace Backend.Models;

public enum GameStatus
{
    Playing,
    Finished,
}

public class Game
{
    public int Id { get; set; }
    public int RoomId { get; set; }
    public Room Room { get; set; } = null!;
    public GameStatus Status { get; set; } = GameStatus.Playing;
    public int CurrentPlayerId { get; set; }
    public int TurnNumber { get; set; } = 1;
    public int Sequence { get; set; }
    public string StateJson { get; set; } = string.Empty;
    public int? WinnerId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? FinishedAt { get; set; }

    public List<GameAction> Actions { get; set; } = new();
}
