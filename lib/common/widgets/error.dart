import 'package:flutter/material.dart';

class ErrorNotice extends StatelessWidget {
  final String error;
  const ErrorNotice({
    Key? key,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(error),
    );
  }
}
