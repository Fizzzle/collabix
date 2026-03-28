part of 'create_group_bloc.dart';

@immutable
sealed class CreateGroupEvent {}

final class CreateGroupRequestedEvent extends CreateGroupEvent {
  final String chatName;
  final String? chatDescription;
  final List<String> participantsIds;
  final String currentUserUid;
  final bool isPrivate;

  CreateGroupRequestedEvent({
    required this.chatName,
    required this.chatDescription,
    required this.participantsIds,
    required this.currentUserUid,
    required this.isPrivate,
  });
}
