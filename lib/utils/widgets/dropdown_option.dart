import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropdownOption {
  final String id; // 식별용
  final String label; // 선택 후 텍스트 필요할 때
  final Widget display; // 보여줄 위젯

  DropdownOption({
    required this.id,
    required this.label,
    required this.display,
  });

  factory DropdownOption.fromText(
      String text,
      {IconData? icon, Color iconColor = Colors.black}) { // 기본색은 검정
    return DropdownOption(
      id: text,
      label: text,
      display: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
