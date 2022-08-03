import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/common.dart';
import 'package:whats_app_clone/features/auth/auth.dart';
import 'package:whats_app_clone/features/features.dart';
import 'package:whats_app_clone/models/models.dart';
import 'package:whats_app_clone/screens/mobile_layout_screen.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserModel?> getCurrentUser() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: verificationId,
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(
        context: context,
        text: e.message!,
      );
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    final navigator = Navigator.of(context);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      navigator.pushNamedAndRemoveUntil(
        UserInfoScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(
        context: context,
        text: e.message!,
      );
    }
  }

  void saveUserData({
    required String name,
    required File? profileImg,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    try {
      String uid = auth.currentUser!.uid;
      String imgUrl =
          'https://png.pngitem.com/pimgs/s/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png';

      if (profileImg != null) {
        imgUrl =
            await ref.read(firebaseStorageRepoProvider).storeFileToFirebase(
                  'profileImg/$uid',
                  profileImg,
                );
      }

      var user = UserModel(
        name: name,
        uid: uid,
        profileImg: imgUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.uid,
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap());

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        text: e.toString(),
      );
    }
  }
}
