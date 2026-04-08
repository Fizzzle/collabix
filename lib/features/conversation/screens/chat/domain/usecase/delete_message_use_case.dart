import 'package:collabix/features/conversation/screens/chat/domain/repository/chat_repo.dart';

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<void> call(String chatId, String messageId) async {
    return repository.deleteMessage(chatId, messageId);
  }
}
