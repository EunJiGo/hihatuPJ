// sections/stations_section.dart

import 'package:flutter/material.dart';

import '../../../presentation/widgets/form_label.dart';
import '../widgets/commuter_text_field.dart';

class StationsSection extends StatelessWidget {
  const StationsSection({
    super.key,
    required this.submissionLocked,
    required this.departureCtrl,
    required this.arrivalCtrl,
    required this.isCommuter,
    required this.hasVia,
    required this.viaCtrls,
    required this.onToggleVia,
    required this.onAddVia,
    required this.onRemoveVia,
    this.onDepartureChanged,
    this.onArrivalChanged,
    this.onViaChanged,
  });

  final bool submissionLocked;
  final TextEditingController departureCtrl;
  final TextEditingController arrivalCtrl;
  final bool isCommuter;
  final bool hasVia;
  final List<TextEditingController> viaCtrls;

  final ValueChanged<bool> onToggleVia;
  final VoidCallback onAddVia;
  final VoidCallback onRemoveVia;

  // 🔽 추가된 콜백들
  final ValueChanged<String>? onDepartureChanged;
  final ValueChanged<String>? onArrivalChanged;
  final void Function(int index, String value)? onViaChanged;

  Widget _arrowDown() =>
      const Center(child: Icon(Icons.south, color: Colors.grey, size: 15));

  @override
  Widget build(BuildContext context) {
    final disabled = submissionLocked ? 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(text: '出発駅', icon: Icons.my_location, iconColor: Color(0xFF81C784)),
        CommuterTextField(
          answerStatus: disabled,
          controller: departureCtrl,
          hintText: '例）荻窪',
          onChanged: onDepartureChanged, // ✅
        ),

        const SizedBox(height: 10),

        if (hasVia) ...[
          const SizedBox(height: 3),
          _arrowDown(),
          Row(
            children: [
              Expanded(
                child: FormLabel(
                  text: '経由駅${viaCtrls.isNotEmpty ? '（${viaCtrls.length}個）' : ''}',
                  icon: Icons.transfer_within_a_station,
                  iconColor: const Color(0xFF81C784),
                ),
              ),
              GestureDetector(onTap: submissionLocked ? null : onAddVia, child: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF0253B3))),
              const SizedBox(width: 15),
              GestureDetector(onTap: submissionLocked || viaCtrls.isEmpty ? null : onRemoveVia, child: const Icon(Icons.remove_circle_outline, size: 18, color: Color(0xFF0253B3))),
            ],
          ),

          for (int i = 0; i < viaCtrls.length; i++) ...[
            if (i != 0) const SizedBox(height: 15),
            CommuterTextField(
              answerStatus: disabled,
              controller: viaCtrls[i],
              hintText: '例）新宿',
              onChanged: (String value) {},
            ),
            const SizedBox(height: 15),
            _arrowDown(),
          ],
        ],

        const FormLabel(text: '到着駅', icon: Icons.location_on, iconColor: Color(0xFF81C784)),
        CommuterTextField(
          answerStatus: disabled,
          controller: arrivalCtrl,
          hintText: '例）品川',
          onChanged: onArrivalChanged, // ✅
        ),

        if(isCommuter)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.transfer_within_a_station, size: 16, color: submissionLocked ? Colors.black26 : hasVia ? const Color(0xFF0253B3) : Colors.grey),
              const SizedBox(width: 3),
              Text(hasVia ? '経由あり' : '経由なし',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: submissionLocked ? Colors.black26 : hasVia ? Colors.black : Colors.black45),
              ),
              const SizedBox(width: 3),
              Transform.translate(
                offset: const Offset(0, -2),
                child: Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: hasVia,
                    onChanged: submissionLocked ? null : onToggleVia,
                    activeColor: submissionLocked ? Colors.black45 : const Color(0xFF0253B3),
                    inactiveThumbColor: submissionLocked ? Colors.black26 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
