import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/conversation/screens/chat/domain/entity/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.messageId,
    required super.content,
    required super.senderId,
    required super.receiverId,
    required super.chatId,
    required super.isRead,
    required super.createdAt,
    super.senderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['createdAt'];
    DateTime createdAt;
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    } else if (createdRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdRaw);
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return MessageModel(
      messageId: json['messageId'] as String,
      content: json['content'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: createdAt,
      senderName: json['senderName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'chatId': chatId,
      'isRead': isRead,
      'createdAt': createdAt,
      if (senderName != null) 'senderName': senderName,
    };
  }
}
