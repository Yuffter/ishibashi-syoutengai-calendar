class UserStatus {
  final bool? isLoggedIn;

  UserStatus({this.isLoggedIn});

  UserStatus copyWith({bool? isLoggedIn}) {
    return UserStatus(isLoggedIn: isLoggedIn ?? this.isLoggedIn);
  }
}