// 타임 라인 박스 1개
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/ui/week/time_label_jst.dart';
import '../../logic/recurrence.dart';
import '../../styles.dart';

class EventBox extends StatelessWidget {
  const EventBox({
    super.key,
    required this.occurrence,
    required this.dayJst,
    this.onTap,
  });

  final Occurrence occurrence;
  final DateTime dayJst; // 지금 이 박스가 속한 캘린더 셀의 JST 날짜(00:00)
  final void Function(Occurrence occ)? onTap;

  // 재사용 가능한 작은 const 위젯들
  static const _iconPerson = Icon(Icons.person, size: 14, color: iosSecondary);
  static const _iconTime = Icon(Icons.access_time, size: 12, color: iosSecondary);
  static const _iconRoom = Icon(Icons.meeting_room, size: 12, color: iosSecondary);

  @override
  Widget build(BuildContext context) {
    // 1) 길이(분) 계산 — "보이는 구간(minHour~maxHour)"으로 클램프한 길이
    //    (보드가 8~19시인데, 이벤트가 19:30~ 시작이면 visibleDurMin=0 → Compact)
    final visibleDurMin = _visibleDurationMinutesLocal(
      occurrence.startLocal,
      occurrence.endLocal,
      dayJst,
    );

    // 2) 시간 라벨(JST 규칙) — 표시에만 사용
    final time = timeLabelForDayJst(
      startRawUtc: occurrence.src.start,
      endRawUtc: occurrence.src.end,
      dayJst: dayJst,
    );

    // 3) 회의실/사람 레이블
    final equipmentLabel = _equipmentNames(occurrence.src.equipments);
    final peopleCount = occurrence.src.people.length;

    // 4) 모드 결정 (디자인 기준 유지)
    final bool isFull = visibleDurMin >= 60;
    final bool isMedium = visibleDurMin >= 30 && visibleDurMin < 60;
    final bool isCompact = visibleDurMin < 30;

    // ── 레이아웃 파라미터 ─────────────────────────────────────────

    // 모드별 패딩(Compact는 매우 타이트)
    final EdgeInsets outerPad = isCompact
        ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
        : const EdgeInsets.all(3);

    final EdgeInsets innerPad = isCompact
        ? const EdgeInsets.only(left: 3) // Compact 때는 왼쪽만 확보
        : const EdgeInsets.all(3);

    // 최소 높이(Compact는 반드시 한 줄 보이도록 보장)
    final BoxConstraints minConstraints = isCompact
        ? const BoxConstraints(minHeight: 16)
        : const BoxConstraints(); // Medium/Full은 최소 높이 강제 X (디자인 유지)

    // 텍스트 스타일
    const titleStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 13);
    const titleStyleCompact = TextStyle(fontWeight: FontWeight.w700, fontSize: 12);
    const subStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: iosSecondary);

    // ── 위젯 트리 ────────────────────────────────────────────────

    return Material(
      color: iosBlue.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: () => onTap?.call(occurrence),
        child: Container(
          padding: outerPad,
          decoration: BoxDecoration(
            border: Border.all(color: iosBlue.withValues(alpha: 0.12), width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            padding: innerPad,
            constraints: minConstraints, // Compact 최소 높이 보장
            clipBehavior: Clip.hardEdge, // 얕을 때 오버플로우 방지
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: iosBlue.withValues(alpha: 0.4), width: 3.0)),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: LayoutBuilder(
                builder: (context, c) {
                  // 아주 얕은 높이에서 Medium/Full이 넘칠 수 있으므로 조건부 스크롤
                  const oneLine = 16.0; // 제목 1줄 대략
                  const twoLines = 34.0; // 제목+서브 한 줄 대략

                  final bool needScrollFull = isFull && c.maxHeight < (twoLines + 10);
                  final bool needScrollMedium = isMedium && c.maxHeight < oneLine;

                  final content = _buildByMode(
                    isFull: isFull,
                    isMedium: isMedium,
                    isCompact: isCompact,
                    titleStyle: isCompact ? titleStyleCompact : titleStyle,
                    subStyle: subStyle,
                    time: time,
                    equipmentLabel: equipmentLabel,
                    peopleCount: peopleCount,
                  );

                  if (needScrollFull || needScrollMedium) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: content,
                    );
                  }
                  return content;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 모드별 UI 분기 (디자인 기준 고정)
  Widget _buildByMode({
    required bool isFull,
    required bool isMedium,
    required bool isCompact,
    required TextStyle titleStyle,
    required TextStyle subStyle,
    required String? time,
    required String equipmentLabel,
    required int peopleCount,
  }) {
    // 공통 헤더: 제목 + (오른쪽에 사람수 뱃지)
    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // ← 가운데 느낌 제거
      children: [
        Expanded(
          child: Text(
            occurrence.src.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: titleStyle,
          ),
        ),
        if (peopleCount > 0)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // ← 위 정렬
            children: [
              _iconPerson,
              const SizedBox(width: 2),
              Text('$peopleCount', style: subStyle),
            ],
          ),
      ],
    );

    // FULL: 제목 + 시간 + 회의실 + 사람수
    if (isFull) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 내용만큼만
        children: [
          header,
          if (time != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                _iconTime,
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: subStyle,
                  ),
                ),
              ],
            ),
          ],
          if (equipmentLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                _iconRoom,
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    equipmentLabel, // 예: "会議室・会議室C・プロジェクター"
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: subStyle,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    // MEDIUM: 제목 + 사람수 (시간/회의실 숨김)
    if (isMedium) {
      return header;
    }

    // COMPACT: 제목만(작게), 오른쪽 사람수 제거(공간 최소화)
    return Text(
      occurrence.src.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: titleStyle, // compact면 위에서 compact 스타일로 내려옴
    );
  }

  // ───────── helpers ─────────

  /// 보이는 구간(보드의 minHour~maxHour)으로 클램프한 "표시 길이(분)"
  int _visibleDurationMinutesLocal(
    DateTime startLocal,
    DateTime endLocal,
    DateTime dayJst,
  ) {
    // 보드가 보여주는 범위(예: 8:00~19:00). minHour/maxHour는 styles.dart에 정의됨.
    final viewStart = DateTime(dayJst.year, dayJst.month, dayJst.day, minHour);
    final viewEnd = DateTime(dayJst.year, dayJst.month, dayJst.day, maxHour);

    final s = startLocal.isBefore(viewStart) ? viewStart : startLocal;
    final e = endLocal.isAfter(viewEnd) ? viewEnd : endLocal;

    final diff = e.difference(s).inMinutes;
    return diff <= 0 ? 0 : diff;
  }

  /// List<Map<String, dynamic>> → 이름 문자열 (중복 제거)
  String _equipmentNames(List<Map<String, dynamic>> equipments) {
    if (equipments.isEmpty) return '';
    final seenIds = <int>{};
    final names = <String>[];
    for (final m in equipments) {
      final id = (m['equipment_id'] as num?)?.toInt();
      final name = (m['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      final added = (id != null) ? seenIds.add(id) : !names.contains(name);
      if (added) names.add(name);
    }
    return names.join('・');
  }
}
