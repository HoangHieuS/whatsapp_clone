import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
