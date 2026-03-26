abstract class CreateChatEntity {
  final String id;
  final String chatName;
  final String chatDescription;
  final List<String> participants;
  final DateTime createdAt;

  CreateChatEntity({
    required this.id,
    required this.chatName,
    required this.chatDescription,
    required this.participants,
    required this.createdAt,
  });
}
