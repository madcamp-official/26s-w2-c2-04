using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models;

public class User
{
    public int Id { get; set; }
    public string? Email { get; set; }
    public string? PasswordHash { get; set; }
    public string Nickname { get; set; } = string.Empty;
    public byte[]? AvatarImage { get; set; }
    public string? AvatarContentType { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [NotMapped]
    public string? AvatarUrl => AvatarImage is null ? null : $"/profile/{Id}/avatar";

    public List<ExternalLogin> ExternalLogins { get; set; } = new();
}
