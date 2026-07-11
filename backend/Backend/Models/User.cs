namespace Backend.Models;

public class User
{
    public int Id { get; set; }
    public string? Email { get; set; }
    public string? PasswordHash { get; set; }
    public string Nickname { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<ExternalLogin> ExternalLogins { get; set; } = new();
}
