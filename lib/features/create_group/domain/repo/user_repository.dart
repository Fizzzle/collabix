import 'package:collabix/core/auth/models/app_user.dart';

abstract class UserRepository {
  Future<List<AppUser>> fetchUsersByNickname(String query);
}
