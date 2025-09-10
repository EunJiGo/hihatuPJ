import 'package:flutter/material.dart';

enum PassDuration { m1, m3, m6 }

extension PassDurationJp on PassDuration {
  String get label {
    switch (this) {
      case PassDuration.m1:
        return '1ヶ月';
      case PassDuration.m3:
        return '3ヶ月';
      case PassDuration.m6:
        return '6ヶ月';
    }
  }
}

class PassDurationRadioRow extends StatelessWidget {
  const PassDurationRadioRow({
    super.key,
    required this.value,               // 현재 선택값
    required this.onChanged,           // 변경 콜백
    required this.isDisabled,
    this.activeColor,
    this.inactiveColor,
    this.scale = 0.6,
    this.fontSize = 14,
    this.gap = 12,
  });

  final PassDuration value;
  final ValueChanged<PassDuration> onChanged;
  final bool isDisabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final double scale;
  final double fontSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = activeColor ?? const Color(0xFF0253B3);
    final unselectedColor = inactiveColor ?? Colors.grey;

    return RadioGroup<PassDuration>(
      groupValue: value,
      onChanged: (v) {
        if (isDisabled) return;           // 비활성화 가드
        if (v == null) return;
        FocusScope.of(context).unfocus();
        onChanged(v);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PassDuration.values.map((duration) {
          final selected = duration == value;
          final textColor = isDisabled
              ? Colors.grey
              : (selected ? selectedColor : unselectedColor);

          return Padding(
            padding: EdgeInsets.only(right: gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Radio<PassDuration>(
                    value: duration,
                    // ✅ groupValue/onChanged 사용 안 함 (RadioGroup이 관리)
                    activeColor: selectedColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                ),
                const SizedBox(width: 2),
                // 라벨 탭 시에도 동일하게 그룹 콜백 타도록
                InkWell(
                  onTap: isDisabled
                      ? null
                      : () {
                    FocusScope.of(context).unfocus();
                    onChanged(duration);
                  },
                  child: Text(
                    duration.label,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

