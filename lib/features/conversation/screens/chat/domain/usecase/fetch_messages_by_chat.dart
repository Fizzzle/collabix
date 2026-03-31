import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/repository/chat_repo.dart';

class FetchMessagesByChatUseCase {
  final ChatRepository repository;

  FetchMessagesByChatUseCase(this.repository);

  Stream<List<MessageModel>> call(String chatId) {
    return repository.getMessagesStream(chatId);
  }
}
