import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hihatu_project/calendar/logic/recurrence.dart';
import 'package:hihatu_project/calendar/styles.dart';

enum NearEdge { top, bottom }

class ScheduleListBody extends StatefulWidget {
  final List<DateTime> days;                           // 전체 범위(오름차순)
  final Map<DateTime, List<Occurrence>> byDay;         // day -> occurrences
  final DateTime focusDay;                             // 진입 시 스냅 기준
  final bool hideEmptyDays;                            // 빈 날 숨김
  final void Function(NearEdge edge, DateTime anchorDay)? onNearEdge; // ⬅️ 추가
  final DateTime? preserveAnchorDay;                   // ⬅추가: 확장 후 보정용
  final void Function(Occurrence occ)? onTapOccurrence; // 상세화면 가기 우한 탭
  final void Function(DateTime day)? onTopDayChanged; // 스크롤할 때 변화하도록


  const ScheduleListBody({
    super.key,
    required this.days,
    required this.byDay,
    required this.focusDay,
    this.hideEmptyDays = false,
    this.onNearEdge,
    this.preserveAnchorDay,
    this.onTapOccurrence, // ← 추가
    this.onTopDayChanged,
  });

  @override
  State<ScheduleListBody> createState() => _ScheduleListBodyState();
}

class _ScheduleListBodyState extends State<ScheduleListBody> {
  final _ctrl = ItemScrollController();
  final _pos  = ItemPositionsListener.create();

  late List<DateTime> _renderDays;               // 빈 날 숨김 반영된 실제 렌더 리스트
  bool _edgeCooldown = false;                    // 과도한 트리거 방지

  int? _lastTopIndex; // 상단 변화 로그 스팸 방지
  bool _ready = false; // 초기 가장자리 감지 억제용

  late final int _initialIndex;
  bool _initialApplied = false;

  bool _suspendEdges = false;

  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _rebuildRenderDays();
    _initialIndex = _findTargetIndex(widget.focusDay);
    debugPrint('[LIST ENTER] focusDay(passed) = ${_dOnly(widget.focusDay)}');
    // 센티넬 활성화는 첫 프레임 이후
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialApplied = true;
      _ready = true;
      _logCurrentTop('AFTER INIT INDEX');
    });

    _pos.itemPositions.addListener(_handleEdgeSentinel);
  }

  @override
  void didUpdateWidget(covariant ScheduleListBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    final needRebuild = oldWidget.hideEmptyDays != widget.hideEmptyDays ||
        oldWidget.days.length != widget.days.length ||
        !_mapEquals(oldWidget.byDay, widget.byDay);

    if (needRebuild) _rebuildRenderDays();

    if (_ctrl.isAttached) {
      // 포커스 스크롤은 그대로
      if (oldWidget.focusDay != widget.focusDay) {
        _ctrl.scrollTo(index: _findTargetIndex(widget.focusDay),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
        Future.delayed(const Duration(milliseconds: 280),
                () => _logCurrentTop('AFTER FOCUS SCROLL'));
        return;
      }

      // ✅ "앞으로(⬆️) 붙였을 때만" 앵커 점프
      if (needRebuild && widget.preserveAnchorDay != null) {
        _performAnchorJump(widget.preserveAnchorDay!);
      }
    }
  }


  @override
  void dispose() {
    _pos.itemPositions.removeListener(_handleEdgeSentinel);
    super.dispose();
  }

  Future<void> _performAnchorJump(DateTime anchor) async {
    final idx = _indexOfDay(_renderDays, anchor);
    if (idx == null) return;

    _suspendEdges = true;
    await _withLayoutReady(() async {
      _ctrl.jumpTo(index: idx);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logCurrentTop('AFTER ANCHOR JUMP');
      // 살짝 더 여유 주고 해제(프레임 1~2개)
      Future.delayed(const Duration(milliseconds: 50), () {
        _suspendEdges = false;
      });
    });
  }

  // 상단 현재 아이템 로그 헬퍼
  void _logCurrentTop(String tag) {
    final positions = _pos.itemPositions.value;
    if (positions.isEmpty || _renderDays.isEmpty) return;
    final minIndex = positions.reduce((a, b) => a.index < b.index ? a : b).index;
    if (minIndex < 0 || minIndex >= _renderDays.length) return;
    final topDay = _renderDays[minIndex];
    debugPrint('[LIST TOP][$tag] topDay = ${_dOnly(topDay)} (idx=$minIndex)');
  }

  void _handleEdgeSentinel() {
    if (!_ready || _suspendEdges) return;           // ★ 초기 점프 끝날 때까진 무시
    if (_renderDays.isEmpty) return;

    final positions = _pos.itemPositions.value;
    if (positions.isEmpty) return;

    final minIndex = positions.reduce((a,b) => a.index < b.index ? a : b).index;
    final maxIndex = positions.reduce((a,b) => a.index > b.index ? a : b).index;

    //  NEW: 맨 위 보이는 아이템 인덱스가 바뀌었을 때만 콜백(스팸 방지)
    if (_lastTopIndex != minIndex) {
      _lastTopIndex = minIndex;
      if (minIndex >= 0 && minIndex < _renderDays.length) {
        final topDay = _renderDays[minIndex];
        widget.onTopDayChanged?.call(topDay);
      }
    }

    if (widget.onNearEdge == null || _edgeCooldown) return;

    const threshold = 3;
    if (minIndex <= threshold) {
      final anchor = _renderDays[minIndex];
      _edgeCooldown = true;
      debugPrint('[EDGE ⬆️] anchor=${_dOnly(anchor)}');
      widget.onNearEdge!(NearEdge.top, anchor);
      Future.delayed(const Duration(milliseconds: 300), () => _edgeCooldown = false);
      return;
    }
    if (maxIndex >= _renderDays.length - 1 - threshold) {
      final anchor = _renderDays[maxIndex];
      _edgeCooldown = true;
      debugPrint('[EDGE ⬇️] anchor=${_dOnly(anchor)}');
      widget.onNearEdge!(NearEdge.bottom, anchor);
      Future.delayed(const Duration(milliseconds: 300), () => _edgeCooldown = false);
    }
  }

  Future<void> _withLayoutReady(Future<void> Function() action) async {
    // itemPositions가 비어있지 않을 때까지 다음 프레임을 기다림
    const maxTries = 10;
    int tries = 0;
    while (_pos.itemPositions.value.isEmpty && tries < maxTries) {
      tries++;
      await Future<void>.delayed(const Duration(milliseconds: 0));
      await WidgetsBinding.instance.endOfFrame; // 프레임 끝까지 대기
    }
    if (_ctrl.isAttached) {
      await action();
    }
  }

  void _rebuildRenderDays() {
    if (widget.hideEmptyDays) {
      _renderDays = widget.days.where((d) {
        final list = widget.byDay[d] ?? const <Occurrence>[];
        return list.isNotEmpty;
      }).toList(growable: false);
    } else {
      _renderDays = List<DateTime>.from(widget.days, growable: false);
    }
  }

  bool _mapEquals(Map<DateTime, List<Occurrence>> a, Map<DateTime, List<Occurrence>> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      final la = a[k] ?? const <Occurrence>[];
      final lb = b[k] ?? const <Occurrence>[];
      if (la.length != lb.length) return false;
      if (la.isNotEmpty && lb.isNotEmpty) {
        // 첫 + 마지막만 체크
        final af = la.first, bf = lb.first;
        final al = la.last,  bl = lb.last;
        if (af.startLocal != bf.startLocal || af.endLocal != bf.endLocal) return false;
        if (al.startLocal != bl.startLocal || al.endLocal != bl.endLocal) return false;
      }
    }
    return true;
  }

  int _findTargetIndex(DateTime focus) {
    if (_renderDays.isEmpty) return 0;
    final f = DateTime(focus.year, focus.month, focus.day);
    final start = _lowerBound(_renderDays, f);
    if (start < _renderDays.length) return start;
    return _renderDays.length - 1;
  }

  int _lowerBound(List<DateTime> arr, DateTime key) {
    int lo = 0, hi = arr.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (!arr[mid].isBefore(key)) hi = mid; else lo = mid + 1;
    }
    return lo;
  }

  int? _indexOfDay(List<DateTime> arr, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final i = _lowerBound(arr, d);
    if (i < arr.length && !arr[i].isBefore(d) && !d.isBefore(arr[i])) return i;
    return null;
  }

  String _dateLabel(DateTime d) {
    const weekday = ['月','火','水','木','金','土','日'];
    final idx = (d.weekday - 1) % 7;
    final wd  = weekday[idx < 0 ? idx + 7 : idx];
    return '${d.year}年${d.month}月${d.day}日（$wd）';
  }

  String _hm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  ({DateTime dayStart, DateTime dayEnd}) _localDayBounds(DateTime any) {
    final d = DateTime(any.year, any.month, any.day);
    return (dayStart: d, dayEnd: d.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)));
  }

  String _buildTimeText(Occurrence s) {
    final b = _localDayBounds(s.startLocal);
    final startClipped = !s.startLocal.isAfter(b.dayStart) && !s.startLocal.isBefore(b.dayStart);
    final eB = _localDayBounds(s.endLocal);
    final endClipped   = !s.endLocal.isBefore(eB.dayEnd) && !s.endLocal.isAfter(eB.dayEnd);
    if (startClipped && endClipped) return '終日';
    if (startClipped) return '~ ${_hm(s.endLocal)}';
    if (endClipped)   return '${_hm(s.startLocal)} ~';
    return '${_hm(s.startLocal)} ~ ${_hm(s.endLocal)}';
  }

  List<String> _equipNames(dynamic raw) {
    if (raw is List) {
      return raw.map((e) {
        if (e is Map) {
          final name = e['name'];
          if (name is String) return name.trim();
        }
        return '';
      }).where((s) => s.isNotEmpty).cast<String>().toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    if (_renderDays.isEmpty) return const SizedBox.shrink();

    return ScrollablePositionedList.builder(
      itemScrollController: _ctrl,
      itemPositionsListener: _pos,
      itemCount: _renderDays.length,
      initialScrollIndex: _initialIndex,
      initialAlignment: 0.0,
      itemBuilder: (ctx, i) {
        final day    = _renderDays[i];
        final slices = widget.byDay[day] ?? const <Occurrence>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFFF2F2F7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(_dateLabel(day),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            for (final s in slices) ...[
              _CardRow(title: s.src.title, peopleCount: s.src.people.length ?? 0, equipmentNames: _equipNames(s.src.equipments), timeText: _buildTimeText(s),onTap: () => widget.onTapOccurrence?.call(s), ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _CardRow extends StatelessWidget {
  final String title;
  final int peopleCount;
  final List<String> equipmentNames;
  final String timeText;
  final VoidCallback? onTap;
  const _CardRow({required this.title, required this.peopleCount, required this.equipmentNames,  required this.timeText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material( // InkWell 리플 위해 Material 감싸기
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF0A84FF).withOpacity(.12),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(
                  color: const Color(0xFF0A84FF).withOpacity(.4), width: 3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(width: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // ← 위 정렬
                          children: [
                            const Icon(Icons.person, size: 14, color: iosSecondary),
                            const SizedBox(width: 2),
                            Text('$peopleCount', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(timeText, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ]),

                    if (equipmentNames.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.meeting_room, size: 12, color: iosSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              equipmentNames.join('・'), // ← 한 줄로 합치기 // 예: "会議室・会議室C・プロジェクター"
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}