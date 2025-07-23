// date_picker_button.dart
import 'package:flutter/material.dart';

class DatePickerButton extends StatelessWidget {
  const DatePickerButton({
    super.key,
    required this.date,
    required this.onPick,
    required this.borderRadius,
    required this.shadowColor,
    required this.backgroundColor,
  });

  final DateTime date;
  final Future<DateTime?> Function() onPick; // 눌렀을 때 날짜를 받아오는 액션
  final double borderRadius;
  final Color shadowColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await onPick();
        // setState는 부모에서 처리
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        // width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${date.year}年${date.month}月${date.day}日',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF263238),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
