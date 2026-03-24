import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/features/register/domain/failures/register_failure.dart';
import 'package:collabix/features/register/domain/repositories/register_repository.dart';

class RegisterService {
  RegisterService(this._repository);

  final RegisterRepository _repository;
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      throw const RegisterFailure('Please enter your full name.');
    }
    if (normalizedEmail.isEmpty || !_emailRegex.hasMatch(normalizedEmail)) {
      throw const RegisterFailure('Please enter a valid email.');
    }
    if (password.length < 6) {
      throw const RegisterFailure('Password must be at least 6 characters.');
    }
    if (password != confirmPassword) {
      throw const RegisterFailure('Passwords do not match.');
    }
    if (!acceptedTerms) {
      throw const RegisterFailure('Accept terms to continue.');
    }

    return _repository.register(
      name: normalizedName,
      email: normalizedEmail,
      password: password,
    );
  }
}
