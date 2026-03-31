import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/create_group/data/model/create_group_model.dart';

abstract class CreateGroupRemoteDataSource {
  Future<CreateGroupModel> createGroup(
    String chatName,
    String chatDescription,
    List<String> participants,
    bool isPrivate,
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
    bool isPrivate,
  ) async {
    final doc = firestore.collection('Groups').doc();

    final chat = CreateGroupModel(
      id: doc.id,
      chatName: chatName,
      chatDescription: chatDescription,
      participants: participants,
      createdAt: DateTime.now(),
      isPrivate: isPrivate,
    );

    final batch = firestore.batch();
    batch.set(doc, chat.toJson());

    for (final uid in participants) {
      final membershipRef = firestore
          .collection('users')
          .doc(uid)
          .collection('Groups')
          .doc(doc.id);
      batch.set(membershipRef, {
        'groupId': doc.id,
        'chatName': chatName,
        'chatDescription': chatDescription,
        'joinedAt': FieldValue.serverTimestamp(),
        'lastPanel': 'chat',
      });
    }

    await batch.commit();

    return chat;
  }
}
