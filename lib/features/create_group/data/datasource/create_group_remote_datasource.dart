import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/create_group/data/model/create_group_model.dart';

abstract class CreateGroupRemoteDataSource {
  Future<CreateGroupModel> createGroup(
    String chatName,
    String chatDescription,
    List<String> participants,
  );
}

class GroupCreationRemoteDataSourceImpl implements CreateGroupRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupCreationRemoteDataSourceImpl(this.firestore);

  @override
  Future<CreateGroupModel> createGroup(
    String chatName,
    String chatDescription,
    List<String> participants,
  ) async {
    final doc = firestore
        .collection(participants.length > 2 ? 'group' : 'dirrect')
        .doc();

    final chat = CreateGroupModel(
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
