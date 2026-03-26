import 'package:collabix/features/create_chat/domain/entity/create_chat_entity.dart';

abstract class CreateChatRepository {
  Future<CreateChatEntity> createChat(
    String chatName,
    String chatDescription,
    List<String> participants,
  );
}
