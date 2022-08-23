import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whats_app_clone/common/common.dart';
import 'package:whats_app_clone/features/features.dart';
import 'package:whats_app_clone/models/models.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUid;
  const ChatList({
    Key? key,
    required this.receiverUid,
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController _msgController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _msgController.dispose();
  }

  void onMessageSwipe(
    String msg,
    bool isMe,
    MessageEnum msgEnum,
  ) {
    ref.read(msgReplyProvider.state).update(
          (state) => MessageReply(
            msg,
            isMe,
            msgEnum,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref.read(chatControllerProvider).chatStream(widget.receiverUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          _msgController.jumpTo(_msgController.position.maxScrollExtent);
        });

        return ListView.builder(
          controller: _msgController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final msgData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(msgData.timeSent);

            if (!msgData.isSeen &&
                msgData.receiverId == FirebaseAuth.instance.currentUser!.uid) {
              ref.read(chatControllerProvider).setChatMsgSeen(
                    context,
                    widget.receiverUid,
                    msgData.messageId,
                  );
            }
            if (msgData.senderId == FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: msgData.text,
                date: timeSent,
                type: msgData.type,
                repliedText: msgData.repliedMessage,
                username: msgData.repliedTo,
                repliedMsgType: msgData.repliedMessageType,
                onLeftSwipe: () => onMessageSwipe(
                  msgData.text,
                  true,
                  msgData.type,
                ),
                isSeen: msgData.isSeen,
              );
            }
            return SenderMessageCard(
              message: msgData.text,
              date: timeSent,
              type: msgData.type,
              repliedText: msgData.repliedMessage,
              username: msgData.repliedTo,
              repliedMsgType: msgData.repliedMessageType,
              onRightSwipe: () => onMessageSwipe(
                msgData.text,
                false,
                msgData.type,
              ),
            );
          },
        );
      },
    );
  }
}
