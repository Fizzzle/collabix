import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/conversation/screens/chat/data/datasource/chat_remote_datasource.dart';
import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/repository/chat_repo.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore firestore;
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.firestore, this.remoteDataSource);

  @override
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true) // Свежие сверху
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    return remoteDataSource.sendMessage(message);
  }
}
