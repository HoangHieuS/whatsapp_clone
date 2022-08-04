import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/features/features.dart';

final getContactProvider = FutureProvider((ref) {
  final selectContactRepo = ref.watch(selectContactRepoProvider);
  return selectContactRepo.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final selectContactRepo = ref.watch(selectContactRepoProvider);
  return SelectContactController(
    selectContactRepo: selectContactRepo,
    ref: ref,
  );
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepo selectContactRepo;

  SelectContactController({
    required this.ref,
    required this.selectContactRepo,
  });

  void selectContact(Contact selectedContact, BuildContext context) {
    selectContactRepo.selectContact(selectedContact, context);
  }
}
