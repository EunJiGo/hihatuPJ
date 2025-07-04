import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const BaseScreen({
    required this.child,
    this.backgroundColor = const Color(0xFFEFF2F4),
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: child,
      ),
    );
  }
}
