import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './terms_of_service_page.dart';
import './privacy_policy_page.dart';

// Providerの定義
// メールアドレスの入力値を管理する
final emailProvider = StateProvider<String>((ref) => '');
// パスワードの入力値を管理する
final passwordProvider = StateProvider<String>((ref) => '');
// パスワードの表示・非表示を管理する
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

// UI（画面）の作成
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      body: Center(
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
                  ref.read(emailProvider.notifier).state = value; // 入力値をProviderに保存
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
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      // アイコンが押されたら、表示/非表示の状態を反転させる
                      ref.read(passwordVisibilityProvider.notifier).update((state) => !state);
                    },
                  ),
                ),
                onChanged: (value) {
                  // 入力値をProviderに保存
                  ref.read(passwordProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 24),

              // ログインボタン
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // ログイン処理
                    print('ログイン試行 Email: $email, Password: $password');
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
                      style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // 利用規約ページに遷移
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                          );
                        },
                    ),
                    const TextSpan(text: 'と'),
                    TextSpan(
                      text: 'プライバシーポリシー',
                      style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // プライバシーポリシーページに遷移
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
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
    );
  }
}