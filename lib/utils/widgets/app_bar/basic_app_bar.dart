// commuter_app_bar.dart
import 'package:flutter/material.dart';

class BasicAppBar extends StatelessWidget {
  final VoidCallback? onBack;
  const BasicAppBar({this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight - 25,
      color: const Color(0xFFFFFFFF),
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack ?? () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xffadadad)),
      ),
    );
  }
}
