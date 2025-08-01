import 'package:flutter/material.dart';

class TransportationTitleSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String title;
  final bool isExpanded;
  final bool isData;
  final double gap;
  final VoidCallback onToggle;

  TransportationTitleSection({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconSize = 25,
    required this.title,
    required this.isExpanded,
    required this.isData,
    this.gap = 8,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize,),
        SizedBox(width: gap),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
            overflow: TextOverflow.ellipsis,  // '...'
            maxLines: 1
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            isData ?
            null
            : isExpanded
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_up_rounded,
            color: Colors.grey.shade700,
            size: 24,
          ),
          onPressed: onToggle,
        ),
      ],
    );
  }
}
