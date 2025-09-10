// lib/calendar/ui/scope/calendar_scope.dart
import 'package:flutter/material.dart';

enum ScopeType { me, person, equipment }

@immutable
class CalendarScopeItem {
  final ScopeType type;
  final String id;     // 'me' or userId or equipmentId
  final String label;  // 표시 텍스트
  final bool enabled;  // 바에 노출할지 (on/off)

  const CalendarScopeItem({
    required this.type,
    required this.id,
    required this.label,
    this.enabled = true,
  });

  CalendarScopeItem copyWith({bool? enabled}) =>
      CalendarScopeItem(
        type: type,
        id: id,
        label: label,
        enabled: enabled ?? this.enabled,
      );
}

/// 임시 데이터
const mockPeopleGroups = <String, List<Map<String, String>>>{
  '営業部': [
    {'id': 'p001', 'name': '田中'},
    {'id': 'p002', 'name': '佐藤'},
    {'id': 'p003', 'name': '鈴木'},
  ],
  '開発部': [
    {'id': 'p101', 'name': '山田'},
    {'id': 'p102', 'name': '高橋'},
  ],
};

const mockEquipments = <Map<String, String>>[
  {'id': 'eA', 'name': '会議室A'},
  {'id': 'eB', 'name': '会議室B'},
  {'id': 'eP', 'name': 'プロジェクター'},
];
