import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

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

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  AuthController(this._authService) : super(const AuthInitial());

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
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _authService.logIn(email: email, password: password);
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
    state = const AuthInitial();
  }
}