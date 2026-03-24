import 'package:collabix/core/auth/models/app_user.dart';

abstract class LoginRepository {
  Future<AppUser> login({
    required String email,
    required String password,
  });
}
