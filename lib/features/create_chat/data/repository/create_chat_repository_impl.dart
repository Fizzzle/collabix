import 'package:collabix/features/create_chat/data/datasource/create_chat_remote_datasource.dart';
import 'package:collabix/features/create_chat/domain/entity/create_chat_entity.dart';
import 'package:collabix/features/create_chat/domain/repo/create_chat_repository.dart';

class CreateChatRepositoryImpl implements CreateChatRepository {
  final CreateChatRemoteDataSource remote;

  CreateChatRepositoryImpl(this.remote);

  @override
  Future<CreateChatEntity> createChat(
    String chatName,
    String chatDescription,
    List<String> participants,
  ) async {
    final chatModel = await remote.createChat(
      chatName,
      chatDescription,
      participants,
    );

    return chatModel;
  }
}
