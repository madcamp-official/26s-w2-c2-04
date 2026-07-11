using Backend.Models;

namespace Backend.Services.OAuth;

public class OAuthProviderResolver(IEnumerable<IOAuthProvider> providers)
{
    public IOAuthProvider? Resolve(string providerName) => providerName.ToLowerInvariant() switch
    {
        "kakao" => providers.First(p => p.Provider == OAuthProvider.Kakao),
        "naver" => providers.First(p => p.Provider == OAuthProvider.Naver),
        "google" => providers.First(p => p.Provider == OAuthProvider.Google),
        _ => null,
    };
}
