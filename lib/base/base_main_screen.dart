import 'package:flutter/material.dart';

class BaseMainScreen extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const BaseMainScreen({
    required this.child,
    this.backgroundColor = const Color(0xFFEFF2F4),
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 상태바 포함 영역을 흰색으로
      body: Column(
        children: [
          // 상태바 높이 확보 + 흰색
          const SafeArea(
            bottom: false,
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(height: 0),
            ),
          ),

          // 아래는 배경색이 EFF2F4
          Expanded(
            child: ColoredBox(
              color: backgroundColor, // = Color(0xFFEFF2F4)
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

