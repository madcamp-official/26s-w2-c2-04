// 프로필 화면(본인 또는 다른 유저)의 로딩 상태를 관리합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
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
  const ProfileLoaded({required this.profile});
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

  /// userId를 안 주면(본인 프로필) GET /profile/me, 주면 GET /profile/{userId}.
  Future<void> load({int? userId}) async {
    state = const ProfileLoading();
    try {
      final profile =
          userId == null ? await _userService.getMyProfile() : await _userService.getProfile(userId);
      state = ProfileLoaded(profile: profile);
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }
}
