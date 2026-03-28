part of 'fetch_all_users_bloc.dart';

@override
sealed class FetchAllUsersEvent {
  const FetchAllUsersEvent();
}

class FetchAllUsersRequestedEvent extends FetchAllUsersEvent {}
class FetchUsersByNicknameRequestedEvent extends FetchAllUsersEvent {
  final String query;

  FetchUsersByNicknameRequestedEvent({required this.query});
}
