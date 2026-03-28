abstract class CreateGroupEntity {
  final String id;
  final String chatName;
  final String chatDescription;
  final List<String> participants;
  bool isPrivate;
  final DateTime createdAt;

  CreateGroupEntity({
    required this.id,
    required this.chatName,
    required this.chatDescription,
    required this.participants,
    required this.createdAt,
    required this.isPrivate,
  });
}
