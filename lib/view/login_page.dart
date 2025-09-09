// lib/view/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_model/login_view_model.dart'; // 生成されたProviderをimport

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // ViewModelの状態を監視
    ref.listen<AsyncValue<User?>>(loginViewModelProvider, (previous, current) {
      // ローディング中は何もしない
      if (current.isLoading) return;

      // エラー時の処理
      if (current.hasError) {
        final error = current.error;
        String errorMessage = 'エラーが発生しました';
        if (error is FirebaseAuthException) {
          // Firebaseの認証エラーコードに応じてメッセージを分岐 [2, 9]
          switch (error.code) {
            case 'user-not-found':
              errorMessage = '指定されたメールアドレスのユーザーは見つかりません。';
              break;
            case 'wrong-password':
              errorMessage = 'パスワードが間違っています。';
              break;
            case 'invalid-email':
              errorMessage = 'メールアドレスの形式が正しくありません。';
              break;
            default:
              errorMessage = 'ログインに失敗しました。';
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        return;
      }

      // 成功時の処理（previousがnullでcurrentがUserオブジェクトの場合）
      if (current.hasValue &&
          current.value != null &&
          (previous == null || previous.value == null)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ログインに成功しました')));
        // 例: ホーム画面へ遷移
        // Navigator.of(context).pushReplacement(...);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                // ViewModelの状態をwatch
                final loginState = ref.watch(loginViewModelProvider);
                // ローディング状態であればインジケーターを表示
                return loginState.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          // ViewModelのloginメソッドを呼び出す
                          ref
                              .read(loginViewModelProvider.notifier)
                              .login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                        },
                        child: const Text('ログイン'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
