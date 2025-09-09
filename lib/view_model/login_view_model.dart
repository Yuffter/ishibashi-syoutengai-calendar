// lib/view_model/login_view_model_simple.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/auth_user.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<User?> build() async {
    // 初期状態はnull
    return null;
  }

  // ログイン処理
  Future<void> login(String email, String password) async {
    // ローディング状態に設定
    state = const AsyncValue.loading();

    // FirebaseAuthを直接使用
    state = await AsyncValue.guard(() async {
      final auth = ref.read(firebaseAuthProvider);
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    });
  }

  // サインアウト処理
  Future<void> signOut() async {
    final auth = ref.read(firebaseAuthProvider);
    await auth.signOut();
    state = const AsyncValue.data(null);
  }
}
