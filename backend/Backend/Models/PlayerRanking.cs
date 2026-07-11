namespace Backend.Models;

public class PlayerRanking
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int PlayerCount { get; set; }
    public int Mmr { get; set; } = 1500;
    public int GamesPlayed { get; set; }
    public int TotalPlaceSum { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public double AvgPlace => GamesPlayed == 0 ? 0 : (double)TotalPlaceSum / GamesPlayed;
}
