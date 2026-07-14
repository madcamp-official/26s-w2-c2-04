import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/player.dart';
import 'package:splendor_multiplayer/models/user_profile.dart';
import 'package:splendor_multiplayer/models/user_stats.dart';
import 'package:splendor_multiplayer/services/user_service.dart';
import 'package:splendor_multiplayer/state/profile_controller.dart';

class _FakeUserService implements UserService {
  UserProfile profile;
  _FakeUserService(this.profile);

  @override
  Future<UserProfile> getProfile(int userId) async => profile;

  @override
  Future<UserStats> getStats(int userId) async => const UserStats(
        userId: 1024,
        gamesPlayed: 10,
        wins: 4,
        avgScore: 12.5,
        avgTurns: 20.0,
      );

  @override
  Future<UserProfile> updateMe({String? nickname, String? avatarUrl}) async {
    profile = profile.copyWith(nickname: nickname ?? profile.nickname);
    return profile;
  }

  @override
  Future<List<Player>> search(String nickname) async => [];
}

void main() {
  test('load는 프로필+전적을 함께 불러와 ProfileLoaded로 만든다', () async {
    final controller = ProfileController(_FakeUserService(
      UserProfile(userId: 1024, nickname: '스플랜더왕', createdAt: DateTime.utc(2026, 7, 10)),
    ));

    await controller.load(1024);

    final state = controller.state as ProfileLoaded;
    expect(state.profile.nickname, '스플랜더왕');
    expect(state.stats.gamesPlayed, 10);
  });

  test('updateNickname은 로드된 프로필의 닉네임만 갱신한다', () async {
    final controller = ProfileController(_FakeUserService(
      UserProfile(userId: 1024, nickname: '스플랜더왕', createdAt: DateTime.utc(2026, 7, 10)),
    ));
    await controller.load(1024);

    await controller.updateNickname('새이름');

    final state = controller.state as ProfileLoaded;
    expect(state.profile.nickname, '새이름');
  });
}
