import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app_clone/features/features.dart';

import '../../../models/models.dart';

final callControllerProvider = Provider((ref) {
  final callRepo = ref.read(callRepoProvider);
  return CallController(
    callRepo: callRepo,
    ref: ref,
    auth: FirebaseAuth.instance,
  );
});

class CallController {
  final CallRepo callRepo;
  final ProviderRef ref;
  final FirebaseAuth auth;
  CallController({
    required this.callRepo,
    required this.ref,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => callRepo.callStream;

  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfileImg, bool isGroupChat) {
    ref.read(userAuthProvider).whenData((value) {
      String callId = const Uuid().v1();

      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerImg: value.profileImg,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverImg: receiverProfileImg,
        callId: callId,
        hasDialled: true,
      );

      Call receiverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerImg: value.profileImg,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverImg: receiverProfileImg,
        callId: callId,
        hasDialled: false,
      );

      callRepo.makeCall(
        senderCallData,
        context,
        receiverCallData,
      );
    });
  }
}
