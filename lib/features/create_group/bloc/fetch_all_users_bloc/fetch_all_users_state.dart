part of 'fetch_all_users_bloc.dart';

@immutable
sealed class FetchAllUsersState {}

final class FetchAllUsersInitial extends FetchAllUsersState {}

final class FetchAllUsersLoading extends FetchAllUsersState {}

final class FetchAllUsersSuccess extends FetchAllUsersState {
  final List<AppUser> users;
  FetchAllUsersSuccess({required this.users});
}

final class FetchAllUsersFailure extends FetchAllUsersState {
  final String error;
  FetchAllUsersFailure({required this.error});
}
