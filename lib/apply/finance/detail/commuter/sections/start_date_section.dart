// sections/start_date_section.dart
import 'package:flutter/material.dart';
import '../../../../presentation/screens/calendar_screen.dart';
import '../../../../presentation/widgets/date_picker_button.dart';
import '../../../../presentation/widgets/form_label.dart';

class StartDateSection extends StatelessWidget {
  const StartDateSection({
    super.key,
    required this.date,
    required this.isReadOnly,
    required this.onPick,
  });

  final DateTime date;
  final bool isReadOnly;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(text: '開始日', icon: Icons.calendar_today, iconColor: Color(0xFF81C784)),
        Center(
          child: DatePickerButton(
            date: date,
            isFullDate: true,
            backgroundColor: isReadOnly ? Colors.grey.shade200 : Colors.white,
            borderRadius: 20,
            shadowColor: const Color(0xFF8e8e8e),
            onPick: () async {
              if (isReadOnly) return date;
              FocusManager.instance.primaryFocus?.unfocus();
              final picked = await Navigator.push<DateTime>(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarScreen(
                    selectedDay: date,
                    titleColor: const Color(0xFF81C784),
                    contentColor: const Color(0xFFFFF8F0),
                  ),
                ),
              );
              if (picked != null) onPick(picked);
              return picked ?? date;
            },
          ),
        ),
      ],
    );
  }
}
