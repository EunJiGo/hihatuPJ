import 'package:flutter/material.dart';

class RoundTripSection extends StatelessWidget {
  final bool isRoundTrip;
  final bool isDisabled;
  final ValueChanged<bool>? onChanged;
  final String onLabel;
  final String offLabel;

  const RoundTripSection({
    super.key,
    required this.isRoundTrip,
    required this.isDisabled,
    this.onChanged,
    this.onLabel = '往復あり',
    this.offLabel = '往復なし',
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF0253B3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.repeat,
          size: 16,
          color: isDisabled
              ? Colors.black26
              : isRoundTrip
              ? activeColor
              : Colors.grey,
        ),
        const SizedBox(width: 3),
        Text(
          isRoundTrip ? onLabel : offLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDisabled
                ? Colors.black26
                : isRoundTrip
                ? activeColor
                : Colors.grey,
          ),
        ),
        const SizedBox(width: 3),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Transform.scale(
            scale: 0.8, // 스위치 크기 살짝 줄임
            child: Switch.adaptive(
              value: isRoundTrip,
              onChanged: isDisabled ? null : onChanged,
              activeColor: isDisabled ? Colors.black45 : activeColor,
            ),
          ),
        ),
      ],
    );
  }
}
