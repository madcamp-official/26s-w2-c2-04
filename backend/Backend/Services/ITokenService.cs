using Backend.Models;

namespace Backend.Services;

public interface ITokenService
{
    string CreateAccessToken(User user, out DateTime expiresAt);
    string CreateRefreshTokenValue();
    string HashRefreshToken(string rawToken);
}
