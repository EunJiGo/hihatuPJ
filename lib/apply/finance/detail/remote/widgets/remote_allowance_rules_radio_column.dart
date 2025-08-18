import 'package:flutter/material.dart';

import '../domain/remote_allowanceRules.dart';

class RemoteAllowanceRulesRadioColumn extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool isDisabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final double scale;
  final double fontSize;
  final double gap;

  const RemoteAllowanceRulesRadioColumn({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDisabled,
    this.activeColor,
    this.inactiveColor,
    this.scale = 0.85,
    this.fontSize = 15,
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = activeColor ?? Color(0xFFfe6966);
    final unselectedColor = Color(0xFFb5b5b5);
    return Column(
      children:
          remoteAllowanceRules.map((rule) {
            final isSelected = rule == value;
            return InkWell(
              onTap: isDisabled ? null : () => onChanged(rule),
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Radio<dynamic>(
                        value: rule,
                        groupValue: value,
                        onChanged: isDisabled ? null : onChanged,
                        activeColor: selectedColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule['label'],
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? isDisabled ? inactiveColor: selectedColor : unselectedColor,
                        ),
                      ),
                    ),
                    Text(
                      '￥${rule['amount']}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? isDisabled ? inactiveColor: selectedColor : unselectedColor,
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
