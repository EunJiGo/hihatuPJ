import 'package:flutter/material.dart';

class QuestionnaireStatus {
  final String label;
  final IconData icon;
  final Color color;

  QuestionnaireStatus({
    required this.label,
    required this.icon,
    required this.color,
  });
}

final List<QuestionnaireStatus> statusList = [
  QuestionnaireStatus(
    label: '未記入',
    icon: Icons.error_outline,
    color: Colors.red,
  ),
  QuestionnaireStatus(
    label: '記入中',
    icon: Icons.warning_amber_outlined,
    color: Colors.amber,
  ),
  QuestionnaireStatus(
    label: '提出済み',
    icon: Icons.check_circle_outline,
    color: Colors.green,
  ),
  QuestionnaireStatus(
    label: '提出期限切れ',
    icon: Icons.schedule,
    color: Colors.black54,
  ),
];
