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
