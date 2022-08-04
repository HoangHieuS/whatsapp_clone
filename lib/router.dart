import 'package:flutter/material.dart';
import 'package:whats_app_clone/features/features.dart';

import 'common/common.dart';
import 'features/chat/screens/mobile_chat_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(verificationId: verificationId),
      );
    case UserInfoScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case SelectContactScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactScreen(),
      );
    case MobileChatScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      final name = args['name'];
      final uid = args['uid'];
      return MaterialPageRoute(
        builder: (context) =>  MobileChatScreen(name: name, uid: uid,),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorNotice(error: 'This page doesn\'t exist'),
        ),
      );
  }
}
