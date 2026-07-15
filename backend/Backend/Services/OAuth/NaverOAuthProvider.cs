using System.Net.Http.Headers;
using System.Text.Json;
using Backend.Models;

namespace Backend.Services.OAuth;

public class NaverOAuthProvider(HttpClient httpClient) : IOAuthProvider
{
    public OAuthProvider Provider => OAuthProvider.Naver;

    public async Task<OAuthUserInfo?> GetUserInfoAsync(string providerToken, CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, "https://openapi.naver.com/v1/nid/me");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", providerToken);

        using var response = await httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
            return null;

        using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var doc = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        var root = doc.RootElement;

        if (root.GetProperty("resultcode").GetString() != "00")
            return null;

        var data = root.GetProperty("response");
        var id = data.GetProperty("id").GetString()!;
        var email = data.TryGetProperty("email", out var emailProp) ? emailProp.GetString() : null;
        var nickname = data.TryGetProperty("nickname", out var nicknameProp) ? nicknameProp.GetString() : null;

        return new OAuthUserInfo(id, email, nickname);
    }
}
