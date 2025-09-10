import 'package:flutter/material.dart';
import '../../../presentation/widgets/form_label.dart';
import '../../summary/widgets/finance_text_field.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({
    super.key,
    required this.controller,
    this.isDisabled = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool isDisabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(
          text: '案件名',
          icon: Icons.work_outline,
          iconColor: const Color(0xFF0253B3),
        ),
        FinanceTextField(
          answerStatus: isDisabled ? 1 : 0,
          controller: controller,
          onChanged: onChanged,
          hintText: '例） 案件名を入力してください。',
        ),
      ],
    );
  }
}
