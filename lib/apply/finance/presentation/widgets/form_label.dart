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
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }
}
