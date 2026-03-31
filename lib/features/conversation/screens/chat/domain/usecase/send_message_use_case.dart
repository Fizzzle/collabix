import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/repository/chat_repo.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(MessageModel message) async {
    return repository.sendMessage(message);
  }
}
