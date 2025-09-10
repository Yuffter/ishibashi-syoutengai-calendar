import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/user_login_input.dart';

part 'user_login_input.g.dart';

@riverpod
class UserLoginInputViewModel extends _$UserLoginInputViewModel {
  @override
  UserLoginInput build() {
    return UserLoginInput(mailAddress: '', password: '');
  }

  /// メールアドレスを更新する
  void updateMail(String mail) {
    state = state.copyWith(mailAddress: mail);
  }

  /// パスワードを更新する
  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  /// メールアドレス
  String get mailAddress => state.mailAddress;
  /// パスワード
  String get password => state.password;
}
