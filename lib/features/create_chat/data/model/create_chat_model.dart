import 'package:collabix/features/create_chat/domain/entity/create_chat_entity.dart';

class CreateChatModel extends CreateChatEntity {
  CreateChatModel({
    required super.id,
    required super.chatName,
    required super.chatDescription,
    required super.participants,
    required super.createdAt,
  });

  factory CreateChatModel.fromJson(Map<String, dynamic> json) {
    return CreateChatModel(
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
