import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/common.dart';

import '../../../models/models.dart';
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

  Stream<List<Group>> chatGroups() {
    return chatRepo.getChatGroups();
  }

  Stream<List<Message>> chatStream(String receiverUid) {
    return chatRepo.getChatStream(receiverUid);
  }

  Stream<List<Message>> groupChatStream(String groupId) {
    return chatRepo.getGroupChatStream(groupId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUid,
    bool isGroupChat,
  ) {
    final msgReply = ref.read(msgReplyProvider);
    ref.read(userAuthProvider).whenData(
          (value) => chatRepo.sendTextMessage(
            context: context,
            text: text,
            receiverUid: receiverUid,
            senderUser: value!,
            msgReply: msgReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(msgReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String receiverUid,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    final msgReply = ref.read(msgReplyProvider);

    ref.read(userAuthProvider).whenData(
          (value) => chatRepo.sendFileMessage(
            context: context,
            file: file,
            receiverUid: receiverUid,
            senderUser: value!,
            messageEnum: messageEnum,
            ref: ref,
            msgReply: msgReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(msgReplyProvider.state).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String receiverUid,
    bool isGroupChat,
  ) {
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    final msgReply = ref.read(msgReplyProvider);

    ref.read(userAuthProvider).whenData(
          (value) => chatRepo.sendGIFMessage(
            context: context,
            gifUrl: newGifUrl,
            receiverUid: receiverUid,
            senderUser: value!,
            msgReply: msgReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(msgReplyProvider.state).update((state) => null);
  }

  void setChatMsgSeen(
    BuildContext context,
    String receiverUid,
    String msgId,
  ) {
    chatRepo.setChatMessageSeen(
      context,
      receiverUid,
      msgId,
    );
  }
}
