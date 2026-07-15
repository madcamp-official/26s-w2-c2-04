namespace Backend.Models;

public class GamePlayerResult
{
    public int Id { get; set; }
    public int GameId { get; set; }
    public Game Game { get; set; } = null!;
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int PlayerCount { get; set; }
    public int Place { get; set; }
    public int Score { get; set; }
    public bool IsRanked { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
