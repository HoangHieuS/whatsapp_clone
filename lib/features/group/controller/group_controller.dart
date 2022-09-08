import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/features/features.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepo = ref.read(groupRepoProvider);
  return GroupController(groupRepo: groupRepo, ref: ref,);
});

class GroupController {
  final GroupRepo groupRepo;
  final ProviderRef ref;

  GroupController({
    required this.groupRepo,
    required this.ref,
  });

  void creaGroup(BuildContext context, String name, File profileImg,
      List<Contact> selectedContact) {
    groupRepo.createGroup(context, name, profileImg, selectedContact,);
  }
}
