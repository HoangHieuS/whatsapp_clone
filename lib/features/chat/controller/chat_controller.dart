import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/models/chat_contact.dart';
import 'package:whats_app_clone/models/message.dart';

import '../../features.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepo = ref.watch(chatRepoProvider);
  return ChatController(
    chatRepo: chatRepo,
    ref: ref,
  );
});

class ChatController {
  final ChatRepo chatRepo;
  final ProviderRef ref;

  ChatController({
    required this.chatRepo,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepo.getChatContact();
  }

  Stream<List<Message>> chatStream(String receiverUid) {
    return chatRepo.getChatStream(receiverUid);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUid,
  ) {
    ref.read(userAuthProvider).whenData(
          (value) => chatRepo.sendTextMessage(
            context: context,
            text: text,
            receiverUid: receiverUid,
            senderUSer: value!,
          ),
        );
  }
}
