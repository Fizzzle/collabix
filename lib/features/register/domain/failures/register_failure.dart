class RegisterFailure implements Exception {
  const RegisterFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
