import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app_clone/common/common.dart';

import '../../../models/models.dart';

final chatRepoProvider = Provider(
  (ref) => ChatRepo(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepo({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContact() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profileImgUrl: user.profileImg,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUid) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUid)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        var msg = Message.fromMap(document.data());
        messages.add(msg);
      }
      return messages;
    });
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        var msg = Message.fromMap(document.data());
        messages.add(msg);
      }
      return messages;
    });
  }

  void _saveDataToContactSubcollection(
    UserModel senderUser,
    UserModel? receiverUser,
    String text,
    DateTime timeSent,
    String receiverUid,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(receiverUid).update({
        'lastMessage': text,
        'timeSent': DateTime.now().microsecondsSinceEpoch,
      });
    } else {
      //display message for another user
      var receiverChatContact = ChatContact(
        name: senderUser.name,
        profileImgUrl: senderUser.profileImg,
        contactId: senderUser.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(receiverUid)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .set(
            receiverChatContact.toMap(),
          );

      //display message for yourself
      var senderChatContact = ChatContact(
        name: receiverUser!.name,
        profileImgUrl: receiverUser.profileImg,
        contactId: receiverUser.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .set(
            senderChatContact.toMap(),
          );
    }
  }

  void _saveMessageToMessageSubcollection({
    required String receiverUid,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? receiverUsername,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUid,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.msg,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : receiverUsername ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.msgEnum,
    );

    if (isGroupChat) {
      await firestore
          .collection('groups')
          .doc(receiverUid)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );

      await firestore
          .collection('users')
          .doc(receiverUid)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUid,
    required UserModel senderUser,
    required MessageReply? msgReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUser;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUid).get();
        receiverUser = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
        senderUser,
        receiverUser,
        text,
        timeSent,
        receiverUid,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUid: receiverUid,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        receiverUsername: receiverUser?.name,
        messageType: MessageEnum.text,
        messageReply: msgReply,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        text: e.toString(),
      );
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUid,
    required UserModel senderUser,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? msgReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var msgId = const Uuid().v1();

      String imgUrl =
          await ref.read(firebaseStorageRepoProvider).storeFileToFirebase(
                'chat/${messageEnum.type}/${senderUser.uid}/$receiverUid/$msgId',
                file,
              );

      UserModel? receiverUser;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUid).get();
        receiverUser = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDataToContactSubcollection(
        senderUser,
        receiverUser,
        contactMsg,
        timeSent,
        receiverUid,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUid: receiverUid,
        text: imgUrl,
        timeSent: timeSent,
        messageId: msgId,
        username: senderUser.name,
        receiverUsername: receiverUser?.name,
        messageType: messageEnum,
        senderUsername: senderUser.name,
        messageReply: msgReply,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        text: e.toString(),
      );
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUid,
    required UserModel senderUser,
    required MessageReply? msgReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUser;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUid).get();
        receiverUser = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
        senderUser,
        receiverUser,
        'GIF',
        timeSent,
        receiverUid,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUid: receiverUid,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        receiverUsername: receiverUser?.name,
        messageType: MessageEnum.gif,
        senderUsername: senderUser.name,
        messageReply: msgReply,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        text: e.toString(),
      );
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUid,
    String msgId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .doc(msgId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(receiverUid)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(msgId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(
        context: context,
        text: e.toString(),
      );
    }
  }
}
