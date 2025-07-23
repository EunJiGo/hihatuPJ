import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PassDuration { m1, m3, m6 }

extension PassDurationJp on PassDuration {
  String get label {
    switch (this) {
      case PassDuration.m1: return '1ヶ月';
      case PassDuration.m3: return '3ヶ月';
      case PassDuration.m6: return '6ヶ月';
    }
  }
}

class PassDurationRadioRow extends StatelessWidget {
  const PassDurationRadioRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.scale = 0.85,
    this.fontSize = 14,
    this.gap = 12,
  });

  final PassDuration value;
  final ValueChanged<PassDuration> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double scale;
  final double fontSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final selectedColor   = activeColor ?? Colors.teal.shade700;
    final unselectedColor = inactiveColor ?? Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PassDuration.values.map((duration) {
        final selected  = duration == value;
        final textColor = selected ? selectedColor : unselectedColor;

        return Padding(
          padding: EdgeInsets.only(right: gap),
          child: InkWell(
            onTap: () => onChanged(duration),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Radio<PassDuration>(
                    value: duration,
                    groupValue: value,
                    onChanged: (d) => d != null ? onChanged(d) : null,
                    activeColor: selectedColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  duration.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}