namespace Backend.Models;

public enum OAuthProvider
{
    Kakao,
    Naver,
    Google,
}

public class ExternalLogin
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public OAuthProvider Provider { get; set; }
    public string ProviderUserId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
