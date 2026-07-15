using Backend.Models;

namespace Backend.Services.OAuth;

public record OAuthUserInfo(string ProviderUserId, string? Email, string? Nickname);

public interface IOAuthProvider
{
    OAuthProvider Provider { get; }

    Task<OAuthUserInfo?> GetUserInfoAsync(string providerToken, CancellationToken cancellationToken);
}
