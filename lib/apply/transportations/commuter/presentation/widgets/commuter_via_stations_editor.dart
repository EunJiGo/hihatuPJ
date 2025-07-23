import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../summary/widgets/form_label.dart';
import 'commuter_text_field.dart';

class ViaStationsEditor extends StatelessWidget {
  const ViaStationsEditor({
    super.key,
    required this.enabled,
    required this.controllers,
    required this.onAdd,
    required this.onRemoveLast,
  });

  final bool enabled;
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final VoidCallback onRemoveLast;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Icon(Icons.south, size: 15, color: Colors.grey)),
        Row(
          children: [
            Expanded(
              child: FormLabel(
                text: '経由駅${controllers.length >= 2 ? '（${controllers.length}）' : ''}',
                icon: Icons.transfer_within_a_station,
                iconColor: const Color(0xFF81C784),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdd,
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: controllers.isNotEmpty ? onRemoveLast : null,
            ),
          ],
        ),
        for (int i = 0; i < controllers.length; i++) ...[
          CommuterTextField(
            answerStatus: 0,
            controller: controllers[i],
            initialAnswer: controllers[i].text,
            onChanged: (_) {}, // 부모에서 이미 controller로 값 접근 가능
            hintText: '例）品川',
          ),
          const Center(child: Icon(Icons.south, size: 15, color: Colors.grey)),
        ],
      ],
    );
  }
}
