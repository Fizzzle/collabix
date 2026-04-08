import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/repository/chat_repo.dart';

class UpdateMessageUseCase {
  final ChatRepository repository;

  UpdateMessageUseCase(this.repository);

  Future<void> call(String chatId, MessageModel message) async {
    return repository.updateMessage(chatId, message);
  }
}
