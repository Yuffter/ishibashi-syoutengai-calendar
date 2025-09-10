import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/view_model/login.dart';
import 'package:hackathon/view_model/user_login_input.dart';
import 'package:hackathon/view_model/user_status.dart';
import './terms_of_service_page.dart';
import './privacy_policy_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// パスワードの表示・非表示を管理する
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

// エラーメッセージを管理するためのProvider
final loginErrorProvider = StateProvider<String?>((ref) => null);

// UI（画面）の作成
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatus = ref.watch(userStatusViewModelProvider.notifier);
    final userLoginInput = ref.watch(userLoginInputViewModelProvider.notifier);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final loginError = ref.watch(loginErrorProvider);

    // ViewModelの状態を監視
    ref.listen<AsyncValue<User?>>(loginViewModelProvider, (previous, current) {
      final errorNotifier = ref.read(loginErrorProvider.notifier);

      // ローディング中はエラーをクリア
      if (current.isLoading) {
        errorNotifier.state = null;
        return;
      }

      // エラー時の処理
      if (current.hasError && !current.isLoading) {
        final error = current.error;
        String errorMessage = 'ログインに失敗しました。もう一度お試しください。';
        if (error is FirebaseAuthException) {
          if (['user-not-found', 'wrong-password', 'invalid-credential']
              .contains(error.code)) {
            errorMessage = 'メールアドレスまたはパスワードが正しくありません。';
          } else if (error.code == 'invalid-email') {
            errorMessage = 'メールアドレスの形式が正しくありません。';
          }
        }
        errorNotifier.state = errorMessage;
        return;
      }

      // 成功時の処理
      if (current.hasValue && current.value != null) {
        final user = current.value!;
        errorNotifier.state = null;

        if (previous?.value == null) { // 以前はログインしていなかった、という条件に修正
          // ログイン状態を更新
          userStatus.updateLoginStatus(true);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('ログインに成功しました')));

          // 初回ログインかどうかを判定
          final metadata = user.metadata;
          final isInitialLogin = metadata.creationTime != null &&
              metadata.lastSignInTime != null &&
              metadata.lastSignInTime!.difference(metadata.creationTime!).inSeconds < 5;

          if (isInitialLogin) {
            // buildContextが非同期ギャップを越えて使われるため、`context.mounted`でチェック
            Future.microtask(() {
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false, // ダイアログの外側をタップしても閉じない
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('ようこそ'),
                      content: const Text(
                          'これは初回ログインです。セキュリティ向上のため、メールアドレスとパスワードの変更をおすすめします。'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('後で'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('変更する'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            // TODO: メールアドレスとパスワードの変更フローを開始する
                            print("パスワード変更フローを開始します");
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            });
          }
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 60),
                  const Text(
                    '石橋商店街カレンダー',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'アプリへのログイン',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'このアプリにログインするには\nメールアドレスとパスワードを入力してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  // メールアドレス入力欄
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // 入力値をProviderに保存
                      ref
                          .read(userLoginInputViewModelProvider.notifier)
                          .updateMail(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // パスワード入力欄
                  TextField(
                    obscureText: !isPasswordVisible, // Providerの値で表示/非表示を切り替え
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // アイコンが押されたら、表示/非表示の状態を反転させる
                          ref
                              .read(passwordVisibilityProvider.notifier)
                              .update((state) => !state);
                        },
                      ),
                    ),
                    onChanged: (value) {
                      // 入力値をProviderに保存
                      ref
                          .read(userLoginInputViewModelProvider.notifier)
                          .updatePassword(value);
                    },
                  ),

                  // エラーメッセージ表示
                  if (loginError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        loginError,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    )
                  else
                    const SizedBox(height: 24.0),

                  // ログインボタン
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // ログイン処理
                        print(
                            'ログイン試行 Email: ${userLoginInput.mailAddress}, Password: ${userLoginInput.password}');
                        ref.read(loginViewModelProvider.notifier).login(
                            userLoginInput.mailAddress,
                            userLoginInput.password);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('ログイン', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 利用規約とプライバシーポリシー
                  Text.rich(
                    TextSpan(
                      text: '「ログイン」をクリックすることで、',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      children: [
                        TextSpan(
                          text: '利用規約',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // 利用規約ページに遷移
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsOfServicePage(),
                                ),
                              );
                            },
                        ),
                        const TextSpan(text: 'と'),
                        TextSpan(
                          text: 'プライバシーポリシー',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // プライバシーポリシーページに遷移
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacyPolicyPage(),
                                ),
                              );
                            },
                        ),
                        const TextSpan(text: 'に同意したことになります。'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
