import 'package:collabix/core/auth/models/app_user.dart';

abstract class RegisterRepository {
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });
}
