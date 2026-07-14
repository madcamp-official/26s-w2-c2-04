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

        // ClientId 설정이 비어있다고 검증을 생략(fail-open)하면 안 됨 - 설정 누락 시 로그인 자체를 거부한다(fail-closed).
        var expectedClientId = configuration["OAuth:Google:ClientId"];
        if (string.IsNullOrEmpty(expectedClientId))
            return null;

        var audience = root.TryGetProperty("aud", out var audProp) ? audProp.GetString() : null;
        if (audience != expectedClientId)
            return null;

        var id = root.GetProperty("sub").GetString()!;
        var email = root.TryGetProperty("email", out var emailProp) ? emailProp.GetString() : null;
        var nickname = root.TryGetProperty("name", out var nameProp) ? nameProp.GetString() : null;

        return new OAuthUserInfo(id, email, nickname);
    }
}
