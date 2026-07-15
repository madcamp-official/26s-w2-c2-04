using System.Net.Http.Headers;
using System.Text.Json;
using Backend.Models;

namespace Backend.Services.OAuth;

public class KakaoOAuthProvider(HttpClient httpClient) : IOAuthProvider
{
    public OAuthProvider Provider => OAuthProvider.Kakao;

    public async Task<OAuthUserInfo?> GetUserInfoAsync(string providerToken, CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, "https://kapi.kakao.com/v2/user/me");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", providerToken);

        using var response = await httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
            return null;

        using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var doc = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        var root = doc.RootElement;

        var id = root.GetProperty("id").GetInt64().ToString();

        string? email = null;
        string? nickname = null;
        if (root.TryGetProperty("kakao_account", out var account))
        {
            if (account.TryGetProperty("email", out var emailProp))
                email = emailProp.GetString();
            if (account.TryGetProperty("profile", out var profile) && profile.TryGetProperty("nickname", out var nicknameProp))
                nickname = nicknameProp.GetString();
        }

        return new OAuthUserInfo(id, email, nickname);
    }
}
