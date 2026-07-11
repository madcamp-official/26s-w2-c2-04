import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';

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
        Navigator.of(context).pushReplacementNamed('/lobby');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: 24),
            if (authState is AuthError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  authState.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            authState is AuthLoading
                ? const CircularProgressIndicator()
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
          ],
        ),
      ),
    );
  }
}