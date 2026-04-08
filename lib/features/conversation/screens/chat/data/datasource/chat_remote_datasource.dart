import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/entity/message_entity.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);
  Future<List<MessageEntity>> getMessages(String chatId);
  Future<void> deleteMessage(String chatId,String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  ChatRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> sendMessage(MessageModel message) async {
    final data = Map<String, dynamic>.from(message.toJson());
    data['createdAt'] = Timestamp.fromDate(message.createdAt);
    await firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.messageId)
        .set(data);

    final preview = {
      'lastMessage': message.content,
      'lastMessageAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('Groups')
        .doc(message.chatId)
        .set(preview, SetOptions(merge: true));

    await firestore
        .collection('users')
        .doc(message.senderId)
        .collection('Groups')
        .doc(message.chatId)
        .set(preview, SetOptions(merge: true));
  }

  @override
  Future<List<MessageEntity>> getMessages(String chatId) async {
    final messages = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    return messages.docs.map((e) => MessageModel.fromJson(e.data())).toList();
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    final selectedMessage = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
