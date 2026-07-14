using System.Security.Claims;

namespace Backend.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static int GetUserId(this ClaimsPrincipal principal)
    {
        var value = principal.FindFirstValue(ClaimTypes.NameIdentifier) ?? principal.FindFirstValue("sub");
        if (value is null)
            throw new InvalidOperationException("인증되지 않은 요청에서 GetUserId()가 호출됐습니다. RequireAuthorization()이 빠진 엔드포인트인지 확인하세요.");
        return int.Parse(value);
    }
}
