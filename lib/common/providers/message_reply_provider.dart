import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/common.dart';

class MessageReply {
  final String msg;
  final bool isMe;
  final MessageEnum msgEnum;

  MessageReply(this.msg, this.isMe, this.msgEnum);
}

final msgReplyProvider = StateProvider<MessageReply?>((ref) => null);
