class UserLoginInput {
  final String mailAddress;
  final String password;

  UserLoginInput({
    required this.mailAddress,
    required this.password,
  });

  UserLoginInput copyWith({
    String? mailAddress,
    String? password,
  }) {
    return UserLoginInput(
      mailAddress: mailAddress ?? this.mailAddress,
      password: password ?? this.password,
    );
  }
}