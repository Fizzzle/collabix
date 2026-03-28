import 'package:bloc/bloc.dart';
import 'package:collabix/features/create_group/domain/entity/create_group_entity.dart';
import 'package:collabix/features/create_group/domain/usecase/create_group_use_case.dart';
import 'package:meta/meta.dart';

part 'create_group_event.dart';
part 'create_group_state.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final CreateGroupUseCase createGroupUseCase;

  CreateGroupBloc(this.createGroupUseCase) : super(CreateGroupInitial()) {
    on<CreateGroupRequestedEvent>(_onCreateGroup);
  }

  Future<void> _onCreateGroup(
    CreateGroupRequestedEvent event,
    Emitter<CreateGroupState> emit,
  ) async {
    emit(CreateGroupLoading());
    try {
      final group = await createGroupUseCase(
        chatName: event.chatName,
        chatDescription: event.chatDescription ?? '',
        participants: event.participantsIds,
        currentUserUid: event.currentUserUid,
        isPrivate: event.isPrivate,
      );
      emit(CreateGroupSuccess(group: group));
    } catch (e) {
      emit(CreateGroupFailure(error: e.toString()));
    }
  }
}
