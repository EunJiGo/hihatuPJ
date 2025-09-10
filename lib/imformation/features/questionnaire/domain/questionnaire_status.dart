import 'package:flutter/material.dart';

class QuestionnaireStatus {
  final String label;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;

  QuestionnaireStatus({
    required this.label,
    required this.icon,
    required this.color,
    this.backgroundColor,
  });
}

final List<QuestionnaireStatus> statusList = [
  QuestionnaireStatus(
    label: '未作成',
    icon: Icons.error_outline,
    color: Colors.red,
    backgroundColor: Colors.red.shade50,
  ),
  QuestionnaireStatus(
    label: '作成中',
    icon: Icons.warning_amber_outlined,
    color: Colors.amber,
    backgroundColor: Colors.amber.shade50,
  ),
  QuestionnaireStatus(
    label: '作成完了',
    icon: Icons.check_circle_outline,
    color: Colors.green,
    backgroundColor: Colors.green.shade50,
  ),
  QuestionnaireStatus(
    label: '提出期限切れ',
    icon: Icons.event_busy,
    color: Colors.black54,
    backgroundColor: Colors.grey.shade300,
  ),
];
