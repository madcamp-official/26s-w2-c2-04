namespace Backend.Models;

public class GameAction
{
    public int Id { get; set; }
    public int GameId { get; set; }
    public Game Game { get; set; } = null!;
    public int Sequence { get; set; }
    public int TurnNumber { get; set; }
    public int PlayerId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string PayloadJson { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
