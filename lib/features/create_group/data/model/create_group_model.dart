import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/create_group/domain/entity/create_group_entity.dart';

class CreateGroupModel extends CreateGroupEntity {
  CreateGroupModel({
    required super.id,
    required super.chatName,
    required super.chatDescription,
    required super.participants,
    required super.isPrivate,
    required super.createdAt,
  });

  factory CreateGroupModel.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['createdAt'];
    DateTime createdAt;
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    } else {
      createdAt = DateTime.now();
    }

    return CreateGroupModel(
      id: json['id'] as String,
      chatName: json['chatName'] as String? ?? '',
      chatDescription: json['chatDescription'] as String? ?? '',
      participants: List<String>.from(
        (json['participants'] as List<dynamic>?)?.map((e) => e.toString()) ??
            const <String>[],
      ),
      createdAt: createdAt,
      isPrivate: json['isPrivate'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatName': chatName,
      'chatDescription': chatDescription,
      'participants': participants,
      'createdAt': createdAt,
      'isPrivate': isPrivate,
    };
  }
}
