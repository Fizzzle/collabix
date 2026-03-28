import 'package:collabix/features/create_group/domain/entity/create_group_entity.dart';

class CreateGroupModel extends CreateGroupEntity {
  CreateGroupModel({
    required super.id,
    required super.chatName,
    required super.chatDescription,
    required super.participants,
    required super.createdAt,
  });

  factory CreateGroupModel.fromJson(Map<String, dynamic> json) {
    return CreateGroupModel(
      id: json['id'],
      chatName: json['chatName'],
      chatDescription: json['chatDescription'],
      participants: json['participants'],
      createdAt: json['createdAt'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatName': chatName,
      'chatDescription': chatDescription,
      'participants': participants,
      'createdAt': createdAt,
    };
  }
}
