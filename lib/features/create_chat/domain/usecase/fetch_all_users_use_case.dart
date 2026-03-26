import 'package:collabix/core/auth/models/app_user.dart';

import '../repo/user_repository.dart';

class FetchAllUsersUseCase {
  final UserRepository repository;

  FetchAllUsersUseCase(this.repository);

  Future<List<AppUser>> call(String query) async {
    return await repository.fetchUsersByNickname(query);
  }
}
