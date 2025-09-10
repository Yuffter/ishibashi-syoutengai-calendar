import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/user_status.dart';

part 'user_status.g.dart';

@riverpod
class UserStatusViewModel extends _$UserStatusViewModel {
  @override
  UserStatus build() {
    return UserStatus(isLoggedIn: false);
  }

  void updateLoginStatus(bool isLoggedIn) {
    state = state.copyWith(isLoggedIn: isLoggedIn);
  }

  bool? get isLoggedIn => state.isLoggedIn;
}
