// data/repositories/user_repo_impl.dart
import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/features/create_chat/data/datasource/user_remote_data_source.dart';
import 'package:collabix/features/create_chat/domain/repo/user_repository.dart';

class UserRepoImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepoImpl(this.remoteDataSource);

  @override
  Future<List<AppUser>> fetchUsersByNickname(String query) async {
    return await remoteDataSource.fetchUsersByNickname(query);
  }
}
