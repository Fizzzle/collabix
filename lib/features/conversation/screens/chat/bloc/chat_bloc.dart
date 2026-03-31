import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/entity/message_entity.dart';
import 'package:collabix/features/conversation/screens/chat/domain/usecase/fetch_messages_by_chat.dart';
import 'package:collabix/features/conversation/screens/chat/domain/usecase/send_message_use_case.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase _sendMessage;
  final FetchMessagesByChatUseCase _fetchMessages;
  StreamSubscription<List<MessageModel>>? _streamSubscription;

  ChatBloc(this._sendMessage, this._fetchMessages) : super(ChatInitial()) {
    on<FetchMessagesByChatEvent>(_onFetchMessagesByChat);
    on<SendMessageEvent>(_onSendMessage);
    on<ChatMessagesSnapshotEvent>(_onMessagesSnapshot);
    on<ChatMessagesStreamErrorEvent>(_onMessagesStreamError);
  }

  void _onMessagesSnapshot(
    ChatMessagesSnapshotEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatLoaded(messages: event.messages));
  }

  void _onMessagesStreamError(
    ChatMessagesStreamErrorEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatFailure(event.message));
  }

  Future<void> _onFetchMessagesByChat(
    FetchMessagesByChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await _streamSubscription?.cancel();

    _streamSubscription = _fetchMessages.call(event.chatId).listen(
      (messages) {
        if (!isClosed) {
          add(ChatMessagesSnapshotEvent(messages));
        }
      },
      onError: (Object e, StackTrace _) {
        if (!isClosed) {
          add(ChatMessagesStreamErrorEvent(e.toString()));
        }
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _sendMessage.call(event.message);
    } catch (e) {
      if (isClosed) return;
      final cur = state;
      if (cur is ChatLoaded) {
        emit(ChatLoaded(messages: cur.messages));
      } else {
        emit(ChatFailure(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
