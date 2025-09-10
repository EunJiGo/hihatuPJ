import 'package:flutter/material.dart';

class StatusExplanation extends StatelessWidget {
  const StatusExplanation({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: const [
        StatusItem(
          icon: Icons.edit,
          text: '臨時保存',
          color: Color(0xFF616161),
          bgColor: Color(0xFFFFF3E0),
        ),
        StatusItem(
          icon: Icons.hourglass_top,
          text: '確認中',
          color: Color(0xFFeece01),
          bgColor: Color(0xFFFFF3E0),
        ),
        StatusItem(
          icon: Icons.check_circle_outline,
          text: '確認完',
          color: Color(0xFF33A1FD),
          bgColor: Color(0xFFE8F5E9),
        ),
        StatusItem(
          icon: Icons.cancel_outlined,
          text: '差戻し',
          color: Color(0xFFE53935),
          bgColor: Color(0xFFFFEBEE),
        ),
      ],
    );
  }
}

class StatusItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;

  const StatusItem({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8,),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
