// sections/duration_section.dart
import 'package:flutter/material.dart';
import '../../../presentation/widgets/form_label.dart';
import '../widgets/commuter_duration.dart';

class DurationSection extends StatelessWidget {
  const DurationSection({
    super.key,
    required this.value,
    required this.isDisabled,
    required this.onChanged,
  });

  final PassDuration value;
  final bool isDisabled;
  final ValueChanged<PassDuration> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(text: '定期券期間', icon: Icons.event_repeat, iconColor: Color(0xFF42A5F5)),
        PassDurationRadioRow(value: value, onChanged: onChanged, isDisabled: isDisabled),
      ],
    );
  }
}
