import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/user_profile.dart';
import 'package:splendor_multiplayer/services/user_service.dart';
import 'package:splendor_multiplayer/state/profile_controller.dart';

class _FakeUserService implements UserService {
  final UserProfile myProfile;
  final UserProfile otherProfile;
  _FakeUserService({required this.myProfile, required this.otherProfile});

  @override
  Future<UserProfile> getMyProfile() async => myProfile;

  @override
  Future<UserProfile> getProfile(int userId) async => otherProfile;
}

void main() {
  test('userId 없이 load하면 GET /profile/me 결과로 ProfileLoaded가 된다', () async {
    final controller = ProfileController(_FakeUserService(
      myProfile: const UserProfile(userId: 1024, nickname: '스플랜더왕', totalGamesPlayed: 10),
      otherProfile: const UserProfile(userId: 2048, nickname: '도시의상인'),
    ));

    await controller.load();

    final state = controller.state as ProfileLoaded;
    expect(state.profile.nickname, '스플랜더왕');
    expect(state.profile.totalGamesPlayed, 10);
  });

  test('userId를 주고 load하면 그 유저의 프로필을 불러온다', () async {
    final controller = ProfileController(_FakeUserService(
      myProfile: const UserProfile(userId: 1024, nickname: '스플랜더왕'),
      otherProfile: const UserProfile(userId: 2048, nickname: '도시의상인'),
    ));

    await controller.load(userId: 2048);

    final state = controller.state as ProfileLoaded;
    expect(state.profile.nickname, '도시의상인');
  });
}
