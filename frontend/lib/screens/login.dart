import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';
import '../theme/app_theme.dart';
import 'signup.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    return Scaffold(
      body: GemBackdrop(
        child: SafeArea(
          child: ScaleToFitForm(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            maxWidth: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'THE GUILD OF GEM MERCHANTS',
                  textAlign: TextAlign.center,
                  style: kickerStyle(letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text('SPLENDOR', style: headingStyle(size: 40, letterSpacing: 6)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.panel.withValues(alpha: 0.92),
                    border: Border.all(color: AppColors.goldFaint),
                  ),
                  child: Column(
                    children: [
                      const OrnateTitle(kicker: 'Welcome back', title: '로그인'),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '이메일',
                          prefixIcon: Icon(Icons.mail_outline, size: 18),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '비밀번호',
                          prefixIcon: Icon(Icons.lock_outline, size: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (authState is AuthError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            authState.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: authState is AuthLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.4),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  ref.read(authControllerProvider.notifier).logIn(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );
                                },
                                child: const Text('로그인'),
                              ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text('아직 계정이 없으신가요? 회원가입'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
