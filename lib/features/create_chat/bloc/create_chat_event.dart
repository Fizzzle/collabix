part of 'create_chat_bloc.dart';

@immutable
sealed class CreateChatEvent {}

final class CreateChatRequestedEvent extends CreateChatEvent {
  final String chatName;
  final String? chatDescription;
  final List<String> participants;

  CreateChatRequestedEvent({
    required this.chatName,
    required this.chatDescription,
    required this.participants,
  });
}
