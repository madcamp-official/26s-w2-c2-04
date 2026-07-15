import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';
import '../theme/app_theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent,
      ),
      body: GemBackdrop(
        child: SafeArea(
          child: ScaleToFitForm(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            maxWidth: 420,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.panel.withValues(alpha: 0.92),
                border: Border.all(color: AppColors.goldFaint),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OrnateTitle(kicker: 'Join the guild', title: '새로운 상인 등록'),
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
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 22),
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
                              ref.read(authControllerProvider.notifier).register(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    nickname: _nicknameController.text,
                                  );
                            },
                            child: const Text('가입하기'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
