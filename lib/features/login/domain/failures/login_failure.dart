class LoginFailure implements Exception {
  const LoginFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
