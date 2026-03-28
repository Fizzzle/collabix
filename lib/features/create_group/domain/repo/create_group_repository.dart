import 'package:collabix/features/create_group/domain/entity/create_group_entity.dart';

abstract class CreateGroupRepository {
  Future<CreateGroupEntity> createGroup(
    String chatName,
    String chatDescription,
    List<String> participants,
    bool isPrivate,
  );
}
