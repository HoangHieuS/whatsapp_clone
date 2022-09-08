import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/features/auth/auth.dart';
import 'package:whats_app_clone/features/status/repo/status_repo.dart';

import '../../../models/models.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepo = ref.read(statusRepoProvider);
  return StatusController(
    statusRepo: statusRepo,
    ref: ref,
  );
});

class StatusController {
  final StatusRepo statusRepo;
  final ProviderRef ref;

  StatusController({
    required this.statusRepo,
    required this.ref,
  });

  void addStatus(File file, BuildContext context) {
    ref.watch(userAuthProvider).whenData((value) {
      statusRepo.uploadStatus(
        username: value!.name,
        profileImg: value.profileImg,
        phoneNumber: value.phoneNumber,
        statusImg: file,
        context: context,
      );
    });
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statuses = await statusRepo.getStatus(context);
    return statuses;
  }
}
