import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whats_app_clone/common/common.dart';

import '../../features.dart';

class DisplayMessage extends StatelessWidget {
  final String msg;
  final MessageEnum type;
  const DisplayMessage({
    Key? key,
    required this.msg,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return type == MessageEnum.text
        ? Text(
            msg,
            style: const TextStyle(fontSize: 16),
          )
        : type == MessageEnum.video
            ? VideoPlayerItem(videoUrl: msg)
            : type == MessageEnum.gif
                ? CachedNetworkImage(imageUrl: msg)
                : CachedNetworkImage(imageUrl: msg);
  }
}
