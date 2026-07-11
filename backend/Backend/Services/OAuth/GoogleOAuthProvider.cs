using System.Text.Json;
using Backend.Models;

namespace Backend.Services.OAuth;

public class GoogleOAuthProvider(HttpClient httpClient, IConfiguration configuration) : IOAuthProvider
{
    public OAuthProvider Provider => OAuthProvider.Google;

    public async Task<OAuthUserInfo?> GetUserInfoAsync(string providerToken, CancellationToken cancellationToken)
    {
        using var response = await httpClient.GetAsync(
            $"https://oauth2.googleapis.com/tokeninfo?id_token={Uri.EscapeDataString(providerToken)}",
            cancellationToken);
        if (!response.IsSuccessStatusCode)
            return null;

        using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var doc = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        var root = doc.RootElement;

        var expectedClientId = configuration["OAuth:Google:ClientId"];
        if (!string.IsNullOrEmpty(expectedClientId))
        {
            var audience = root.TryGetProperty("aud", out var audProp) ? audProp.GetString() : null;
            if (audience != expectedClientId)
                return null;
        }

        var id = root.GetProperty("sub").GetString()!;
        var email = root.TryGetProperty("email", out var emailProp) ? emailProp.GetString() : null;
        var nickname = root.TryGetProperty("name", out var nameProp) ? nameProp.GetString() : null;

        return new OAuthUserInfo(id, email, nickname);
    }
}
