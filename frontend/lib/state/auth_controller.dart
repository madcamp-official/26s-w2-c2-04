import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/social_socket_service.dart';
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
    ref.read(socialSocketProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenStorage _tokenStorage;
  final SocialSocket _socialSocket;
  AuthController(this._authService, this._tokenStorage, this._socialSocket)
      : super(const AuthInitial());

  /// 동시접속(다른 기기/브라우저에서 이미 로그인 중)일 때 사용자에게 보여줄 안내.
  static const _concurrentLoginMessage = '다른 기기 또는 브라우저에서 이미 로그인되어 있습니다.';

  /// 로그인 상태로 들어가는 모든 경로(회원가입/로그인 성공, 세션 복원)에서
  /// SocialHub에 상시 연결해야 서버가 "같은 계정으로 로그인 중"을 정확히
  /// 판단해 동시접속을 차단할 수 있다.
  ///
  /// 반환값: 로그인을 계속 진행해도 되면 true. 서버가 동시접속으로 연결을 거부
  /// (ALREADY_LOGGED_IN)하면 false를 돌려주어 호출부가 로그인 자체를 되돌리게
  /// 한다. 그 외 실패(네트워크 순단 등)는 로그인 흐름을 막지 않으려고 true로
  /// 취급한다 — SocialHub는 자동 재연결로 이후 다시 붙는다.
  Future<bool> _connectSocialSocket(String accessToken) async {
    try {
      await _socialSocket.connect(accessToken);
      return true;
    } catch (e) {
      if (_isConcurrentLogin(e)) return false;
      return true;
    }
  }

  /// SocialHub가 동시접속으로 연결을 거부하면 HubException("ALREADY_LOGGED_IN")을
  /// 던지고, signalr_netcore가 그 메시지를 그대로 감싸 던지므로 코드 문자열로
  /// 판별한다.
  bool _isConcurrentLogin(Object error) =>
      error.toString().contains('ALREADY_LOGGED_IN');

  /// 동시접속으로 로그인이 거부됐을 때, 이미 세워둔 세션을 완전히 되돌린다.
  Future<void> _rollbackConcurrentLogin() async {
    try {
      await _socialSocket.disconnect();
    } catch (_) {
      // 정리 실패는 무시 — 어차피 로그인 상태를 버린다.
    }
    await _tokenStorage.clear();
    state = const AuthError(_concurrentLoginMessage);
  }

  /// 앱 시작 시 한 번 호출해서 저장된 세션이 있으면 복원합니다.
  /// accessToken이 만료됐더라도 ApiClient가 refreshToken으로 자동 갱신을 시도하므로,
  /// 여기서는 별도의 유효성 검사 없이 저장된 사용자를 그대로 신뢰합니다.
  Future<void> restoreSession() async {
    final user = await _tokenStorage.readUser();
    if (user == null) return;
    // 정상 부팅(대부분의 경우)에는 곧바로 홈으로 보내야 하므로 먼저
    // AuthAuthenticated로 전이한 뒤 소켓을 붙인다. 동시접속으로 거부되면
    // 아래에서 세션을 되돌려 로그인 화면 + 안내로 되돌아간다.
    state = AuthAuthenticated(user);
    if (!await _connectSocialSocket(user.accessToken)) {
      await _rollbackConcurrentLogin();
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
      // 로그인 화면은 AuthAuthenticated를 보는 즉시 홈으로 넘어가므로, 동시접속
      // 여부를 먼저 확인한 뒤에만 인증 상태를 확정하고 토큰을 저장한다.
      if (!await _connectSocialSocket(user.accessToken)) {
        await _rollbackConcurrentLogin();
        return;
      }
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
      if (!await _connectSocialSocket(user.accessToken)) {
        await _rollbackConcurrentLogin();
        return;
      }
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
    try {
      await _socialSocket.disconnect();
    } catch (_) {
      // 로그아웃 자체는 계속 진행한다.
    }
    await _tokenStorage.clear();
    state = const AuthInitial();
  }
}