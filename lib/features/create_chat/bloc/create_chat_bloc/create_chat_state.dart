part of 'create_chat_bloc.dart';

@immutable
sealed class CreateChatState {}

final class CreateChatInitial extends CreateChatState {}

final class CreateChatLoading extends CreateChatState {}

final class CreateChatSuccess extends CreateChatState {
  final CreateChatEntity chat;
  CreateChatSuccess({required this.chat});
}

final class CreateChatFailure extends CreateChatState {
  final String error;
  CreateChatFailure({required this.error});
}
