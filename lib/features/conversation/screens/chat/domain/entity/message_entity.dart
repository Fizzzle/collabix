abstract class MessageEntity {
  final String messageId;
  final String content;
  final String senderId;
  final String receiverId;
  final String chatId;
  final bool isRead;
  final DateTime createdAt;
  /// Denormalized for UI (first letter avatar); optional for older docs.
  final String? senderName;

  MessageEntity({
    required this.messageId,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.isRead,
    required this.createdAt,
    this.senderName,
  });
}
