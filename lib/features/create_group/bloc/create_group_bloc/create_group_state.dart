part of 'create_group_bloc.dart';

@immutable
sealed class CreateGroupState {}

final class CreateGroupInitial extends CreateGroupState {}

final class CreateGroupLoading extends CreateGroupState {}

final class CreateGroupSuccess extends CreateGroupState {
  final CreateGroupEntity group;
  CreateGroupSuccess({required this.group});
}

final class CreateGroupFailure extends CreateGroupState {
  final String error;
  CreateGroupFailure({required this.error});
}
