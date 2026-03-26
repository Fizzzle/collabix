import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/create_chat/data/model/create_chat_model.dart';

abstract class CreateChatRemoteDataSource {
  Future<CreateChatModel> createChat(
    String chatName,
    String chatDescription,
    List<String> participants,
  );
}

class ChatCreationRemoteDataSourceImpl implements CreateChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatCreationRemoteDataSourceImpl(this.firestore);

  @override
  Future<CreateChatModel> createChat(
    String chatName,
    String chatDescription,
    List<String> participants,
  ) async {
    final doc = firestore.collection('chats').doc();

    final chat = CreateChatModel(
      id: doc.id,
      chatName: chatName,
      chatDescription: chatDescription,
      participants: participants,
      createdAt: DateTime.now(),
    );

    await doc.set(chat.toJson());

    return chat;
  }
}
