part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;

  ChatLoaded({required this.messages});
}

class ChatFailure extends ChatState {
  final String message;
  ChatFailure(this.message);
}

class ChatMessageDeleted extends ChatState {}

class ChatMessageUpdated extends ChatState {
  final MessageEntity message;
  ChatMessageUpdated({required this.message});
}

class ChatMessageUpdateFailure extends ChatState {
  final String message;
  ChatMessageUpdateFailure({required this.message});
}
