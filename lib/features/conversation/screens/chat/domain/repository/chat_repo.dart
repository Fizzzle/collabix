import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';

abstract class ChatRepository {
  Stream<List<MessageModel>> getMessagesStream(String chatId);
  Future<void> sendMessage(MessageModel message);
  Future<void> deleteMessage(String chatId, String messageId);

  // Future<void> markMessageAsRead(String messageId);
  // Future<void> deleteMessage(String messageId);
  // Future<void> updateMessage(MessageEntity message);
}
