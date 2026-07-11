namespace Backend.Dtos;

public record RegisterRequest(string Email, string Password, string Nickname);

public record LoginRequest(string Email, string Password);

public record KakaoOAuthRequest(string KakaoAccessToken);

public record NaverOAuthRequest(string NaverAccessToken);

public record GoogleOAuthRequest(string IdToken);

public record LinkProviderRequest(string ProviderToken);

public record RefreshRequest(string RefreshToken);

public record AuthResponse(
    int UserId,
    string Nickname,
    string Provider,
    string AccessToken,
    string RefreshToken,
    int ExpiresIn);

public record OAuthAuthResponse(
    int UserId,
    string Nickname,
    string Provider,
    string AccessToken,
    string RefreshToken,
    int ExpiresIn,
    bool IsNewUser);

public record LinkResponse(List<string> LinkedProviders);

public record RefreshResponse(string AccessToken, int ExpiresIn);

public record MeResponse(
    int UserId,
    string? Email,
    string Nickname,
    string? AvatarUrl,
    List<string> LinkedProviders,
    DateTime CreatedAt);
