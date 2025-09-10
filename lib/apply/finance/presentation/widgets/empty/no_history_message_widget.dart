import 'package:flutter/material.dart';

class NoHistoryMessage extends StatefulWidget {
  const NoHistoryMessage({super.key});

  @override
  State<NoHistoryMessage> createState() => _NoHistoryMessageState();
}

class _NoHistoryMessageState extends State<NoHistoryMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // 약간 아래에서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history, // 👈 아이콘 변경 가능
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              '申請履歴がないです。\n交通費及び定期券を申請してください。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.5, // 줄 간격
              ),
            ),
          ],
        ),
      ),
    );
  }
}
