part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

final class SendMessageEvent extends ChatEvent {
  final MessageModel message;

  SendMessageEvent({required this.message});
}

final class FetchMessagesByChatEvent extends ChatEvent {
  final String chatId;

  FetchMessagesByChatEvent({required this.chatId});
}

final class ChatMessagesSnapshotEvent extends ChatEvent {
  ChatMessagesSnapshotEvent(this.messages);

  final List<MessageModel> messages;
}

final class ChatMessagesStreamErrorEvent extends ChatEvent {
  ChatMessagesStreamErrorEvent(this.message);

  final String message;
}

final class DeleteMessageEvent extends ChatEvent {
  DeleteMessageEvent({required this.chatId, required this.messageId});
  final String chatId; 
  final String messageId;

}
