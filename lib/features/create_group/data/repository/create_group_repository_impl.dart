import 'package:collabix/features/create_group/data/datasource/create_group_remote_datasource.dart';
import 'package:collabix/features/create_group/domain/entity/create_group_entity.dart';
import 'package:collabix/features/create_group/domain/repo/create_group_repository.dart';

class CreateGroupRepositoryImpl implements CreateGroupRepository {
  final CreateGroupRemoteDataSource remote;

  CreateGroupRepositoryImpl(this.remote);

  @override
  Future<CreateGroupEntity> createGroup(
    String chatName,
    String chatDescription,
    List<String> participants,
  ) async {
    final groupModel = await remote.createGroup(
      chatName,
      chatDescription,
      participants,
    );

    return groupModel;
  }
}
