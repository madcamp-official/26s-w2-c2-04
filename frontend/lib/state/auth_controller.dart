import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

final authServiceProvider = Provider((ref) => AuthService());
final tokenStorageProvider = Provider((ref) => TokenStorage());

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenStorage _tokenStorage;
  AuthController(this._authService, this._tokenStorage)
      : super(const AuthInitial());

  /// 앱 시작 시 한 번 호출해서 저장된 세션이 있으면 복원합니다.
  /// accessToken이 만료됐더라도 ApiClient가 refreshToken으로 자동 갱신을 시도하므로,
  /// 여기서는 별도의 유효성 검사 없이 저장된 사용자를 그대로 신뢰합니다.
  Future<void> restoreSession() async {
    final user = await _tokenStorage.readUser();
    if (user != null) {
      state = AuthAuthenticated(user);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        nickname: nickname,
      );
      await _tokenStorage.saveUser(user);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _authService.logIn(email: email, password: password);
      await _tokenStorage.saveUser(user);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logOut() async {
    final current = state;
    if (current is AuthAuthenticated) {
      await _authService.logOut(current.user.accessToken);
    }
    await _tokenStorage.clear();
    state = const AuthInitial();
  }
}