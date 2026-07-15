import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// /auth/register, /auth/login 응답 구조
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int userId,
    required String nickname,
    required String provider, // "email" | "kakao" | "naver" | "google"
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}