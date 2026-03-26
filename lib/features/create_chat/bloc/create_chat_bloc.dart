import 'package:bloc/bloc.dart';
import 'package:collabix/features/create_chat/domain/entity/create_chat_entity.dart';
import 'package:collabix/features/create_chat/domain/usecase/create_chat_use_case.dart';
import 'package:meta/meta.dart';

part 'create_chat_event.dart';
part 'create_chat_state.dart';

class CreateChatBloc extends Bloc<CreateChatEvent, CreateChatState> {
  final CreateChatUseCase createChatUseCase;

  CreateChatBloc(this.createChatUseCase) : super(CreateChatInitial()) {
    on<CreateChatRequestedEvent>(_onCreateChat);
  }

  Future<void> _onCreateChat(
    CreateChatRequestedEvent event,
    Emitter<CreateChatState> emit,
  ) async {
    emit(CreateChatLoading());
    try {
      final chat = await createChatUseCase(
        chatName: event.chatName,
        chatDescription: event.chatDescription ?? '',
        participants: event.participants,
      );
      emit(CreateChatSuccess(chat: chat));
    } catch (e) {
      emit(CreateChatFailure(error: e.toString()));
    }
  }
}
