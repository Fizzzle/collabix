import 'package:collabix/features/create_chat/domain/entity/create_chat_entity.dart';
import 'package:collabix/features/create_chat/domain/repo/create_chat_repository.dart';

class CreateChatUseCase {
  final CreateChatRepository repository;

  CreateChatUseCase(this.repository);

  Future<CreateChatEntity> call({
    required String chatName,
    required String chatDescription,
    required List<String> participants,
  }) {
    return repository.createChat(chatName, chatDescription, participants);
  }
}
