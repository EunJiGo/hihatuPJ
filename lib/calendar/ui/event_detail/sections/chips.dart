import 'package:flutter/material.dart';

// 칩 공용
Widget buildChip({
  required IconData icon,
  required String label,
  required Color background,
  required Color foreground,
}) {
  return Chip(
    avatar: Icon(icon, size: 16, color: foreground),
    label: Text(label),
    side: BorderSide.none,
    shape: const StadiumBorder(),
    backgroundColor: background,
    labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
    visualDensity: VisualDensity.compact,
  );
}

Widget personChip(
    String name, {
      required Color avatarBg,
      required Color avatarFg,
      Color chipBg = Colors.white,
      Color? textColor,
    }) {
  final initial = name.isNotEmpty ? name.substring(0, 1) : '?';
  return Chip(
    label: Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: avatarBg,
          child: Text(initial, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: avatarFg)),
        ),
        const SizedBox(width: 6),
        Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      ],
    ),
    backgroundColor: chipBg,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    labelPadding: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    side: BorderSide.none,
    shape: const StadiumBorder(),
  );
}
