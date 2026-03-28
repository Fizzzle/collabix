import 'package:collabix/features/create_group/domain/entity/create_group_entity.dart';
import 'package:collabix/features/create_group/domain/repo/create_group_repository.dart';

class CreateGroupUseCase {
  final CreateGroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<CreateGroupEntity> call({
    required String chatName,
    required String chatDescription,
    required List<String> participants,
    required String currentUserUid,
    required bool isPrivate,
  }) {
    final allParticipants = [...participants, currentUserUid].toSet().toList();
    return repository.createGroup(
      chatName,
      chatDescription,
      allParticipants,
      isPrivate,
    );
  }
}
