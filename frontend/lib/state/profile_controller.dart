// 프로필 화면(본인 또는 친구)의 로딩 상태를 관리합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/user_stats.dart';
import '../services/user_service.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final UserStats stats;
  const ProfileLoaded({required this.profile, required this.stats});
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

final userServiceProvider = Provider((ref) => UserService());

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ProfileState>((ref) {
  return ProfileController(ref.read(userServiceProvider));
});

class ProfileController extends StateNotifier<ProfileState> {
  final UserService _userService;
  ProfileController(this._userService) : super(const ProfileInitial());

  Future<void> load(int userId) async {
    state = const ProfileLoading();
    try {
      final profile = await _userService.getProfile(userId);
      final stats = await _userService.getStats(userId);
      state = ProfileLoaded(profile: profile, stats: stats);
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }

  Future<void> updateNickname(String nickname) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    try {
      final updated = await _userService.updateMe(nickname: nickname);
      state = ProfileLoaded(
        profile: current.profile.copyWith(nickname: updated.nickname),
        stats: current.stats,
      );
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }
}
