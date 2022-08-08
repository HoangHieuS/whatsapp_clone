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

  void _saveDataToContactSubcollection(
    UserModel senderUser,
    UserModel receiverUser,
    String text,
    DateTime timeSent,
    String receiverUid,
  ) async {
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
        .collection('contacts')
        .doc(senderUser.uid)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          receiverChatContact.toMap(),
        );

    //display message for yourself
    var senderChatContact = ChatContact(
      name: receiverUser.name,
      profileImgUrl: receiverUser.profileImg,
      contactId: receiverUser.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('contacts')
        .doc(senderUser.uid)
        .collection('chats')
        .doc(receiverUid)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubcollection({
    required String receiverUid,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String receiverUsername,
    required MessageEnum messageType,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUid,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );
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

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUid,
    required UserModel senderUSer,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUser;

      var userDataMap =
          await firestore.collection('users').doc(receiverUid).get();
      receiverUser = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
        senderUSer,
        receiverUser,
        text,
        timeSent,
        receiverUid,
      );

      _saveMessageToMessageSubcollection(
        receiverUid: receiverUid,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUSer.name,
        receiverUsername: receiverUser.name,
        messageType: MessageEnum.text,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        text: e.toString(),
      );
    }
  }
}
