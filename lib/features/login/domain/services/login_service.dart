import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/features/login/domain/failures/login_failure.dart';
import 'package:collabix/features/login/domain/repositories/login_repository.dart';

class LoginService {
  LoginService(this._repository);

  final LoginRepository _repository;
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || !_emailRegex.hasMatch(normalizedEmail)) {
      throw const LoginFailure('Please enter a valid email.');
    }
    if (password.isEmpty) {
      throw const LoginFailure('Please enter your password.');
    }

    return _repository.login(email: normalizedEmail, password: password);
  }
}
