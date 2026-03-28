import 'package:bloc/bloc.dart';
import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/features/create_group/domain/usecase/fetch_all_users_use_case.dart';
import 'package:meta/meta.dart';

part 'fetch_all_users_event.dart';
part 'fetch_all_users_state.dart';

class FetchAllUsersBloc extends Bloc<FetchAllUsersEvent, FetchAllUsersState> {
  final FetchAllUsersUseCase fetchAllusersUseCase;
  FetchAllUsersBloc(this.fetchAllusersUseCase) : super(FetchAllUsersInitial()) {
    on<FetchAllUsersRequestedEvent>(_onLoadUsers);
    on<FetchUsersByNicknameRequestedEvent>(_onSearchUsers);
  }
  _onLoadUsers(
    FetchAllUsersRequestedEvent event,
    Emitter<FetchAllUsersState> emit,
  ) async {
    emit(FetchAllUsersInitial());
  }

  Future<void> _onSearchUsers(
    FetchUsersByNicknameRequestedEvent event,
    Emitter<FetchAllUsersState> emit,
  ) async {
    final normalizedQuery = event.query.trim();
    if (normalizedQuery.isEmpty) {
      emit(FetchAllUsersInitial());
      return;
    }

    emit(FetchAllUsersLoading());
    try {
      final users = await fetchAllusersUseCase(normalizedQuery);
      emit(FetchAllUsersSuccess(users: users));
    } catch (e) {
      emit(FetchAllUsersFailure(error: e.toString()));
    }
  }
}
