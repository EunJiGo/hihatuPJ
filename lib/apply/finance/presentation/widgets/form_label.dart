import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const FormLabel({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(icon, size: 16, color: iconColor),
          Icon(icon, size: 16, color: Color(0xFF0253B3)),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }
}
