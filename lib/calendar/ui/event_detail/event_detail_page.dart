import 'package:flutter/material.dart';
import '../../apply/finance/detail/summary/sections/action_bar_section.dart';
import '../../utils/date/date_utils.dart'; // parseUtc 사용
import '../../utils/dialog/success_dialog.dart';
import '../../utils/dialog/warning_dialog.dart';
import '../data/fetch_calendar_delete.dart';
import '../domain/calendar_single.dart'; // 단일 이벤트(스케줄) 정보를 담는 모델
import '../styles.dart'; // iosBlue 등 쓰면 유지, 아니면 Theme로 대체 가능
import 'package:url_launcher/url_launcher.dart';
import 'shared/header.dart'; // 외부 URL 열기 (pubspec에 추가 필요)

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.event,
    required this.pivotJst,
  });

  final CalendarSingle event;
  final DateTime pivotJst;

  @override
  Widget build(BuildContext context) {
    final startUtc = parseUtc(event.start);
    final endUtc = parseUtc(event.end);

    // 안전 처리
    final start = startUtc ?? DateTime.now().toUtc();
    final end = endUtc ?? start.add(const Duration(minutes: 30));

    final jstStart = _toJst(start);
    final jstEnd = _toJst(end);

    final period = _formatRangeJst(jstStart, jstEnd);
    final isSecret = event.isSecret == 1;

    final equipments = event.equipments
        .map((e) => (e['name'] as String?)?.trim())
        .where((e) => (e != null && e.isNotEmpty))
        .cast<String>()
        .toList();

    final attendees = event.people
        .map((e) => (e['name'] as String?)?.trim())
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toSet() // 중복 제거
        .toList();

    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    void _showLoadingDialog(BuildContext context, {String message = '処理中…'}) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(false);
            return false;
          },
          child: Dialog(
            backgroundColor: const Color(0xFFdddddd),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    /// fetchTransportationDelete의 반환 타입에 상관없이 "성공"을 추정
    Future<void> _onDeleteEvent() async {
      // (확인 다이얼로그 제거)
      _showLoadingDialog(context, message: '削除中…');

      try {
        final success = await fetchCalendarDelete(event.id);

        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // ← 로딩 닫기 복구!

        if (!success) {
          await warningDialog(context, '削除に失敗しました', 'しばらくしてからもう一度お試しください。');
          return;
        }
        await successDialog(context, '削除しました', '予定を削除しました。');

        if (!context.mounted) return;
        Navigator.of(context).pop(true);
      } catch (_) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // ← 로딩 닫기
          await warningDialog(context, '削除に失敗しました', 'ネットワークエラーが発生しました。もう一度お試しください。');
        }
      }
    }




    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ScheduleHeader.detail(
          monthForTitle: pivotJst,
          onTapBackDetail: () => Navigator.of(context).pop(true),
          onTapEdit: () {
            // TODO: 편집 화면으로 이동
            // Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPage(event: event)));
          },
          hideWeekdayLabels: true,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더 카드
                Card(
                  elevation: 0,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  //   side: BorderSide(color: color.outlineVariant),
                  // ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        event.title.isEmpty ? '(タイトルなし)' : event.title,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                        ),
                        softWrap: true, // 줄바꿈 허용
                        // maxLines: 2,
                        // overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // 기간
                      Text(
                        period,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: iosLabel.withValues(alpha: 0.65),
                        ),
                      ),
                      // 반복
                      // 반복
                      _RepeatInfo(ev: event),

                      // 공개/활성 Chip들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _chip(
                                icon: isSecret ? Icons.lock : Icons.lock_open,
                                label: isSecret ? '秘' : '公',
                                background: (isSecret
                                    ? Colors.amber.withValues(alpha: 0.4)
                                    : iosBlue.withValues(alpha: 0.18)),
                                foreground: (isSecret ? Colors.brown : iosBlue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 본문 카드
                Container(
                  color: Colors.white,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        height: 1, // 높이
                        thickness: 1, // 선 굵기
                        color: Colors.black12, // 색상
                      ),
                      SizedBox(height: 10),
                      // 상세내용
                      if (event.details.trim().isNotEmpty) ...[
                        _LabeledBlock(
                          title: '詳細内容',
                          icon: Icons.notes, // 원하면 null로
                          child: SelectableText(
                            event.details.trim(),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 1, // 높이
                          thickness: 1, // 선 굵기
                          color: Colors.black12, // 색상
                        ),
                      ],

                      // 작성자
                      if (event.createdByName.trim().isNotEmpty) ...[
                        SizedBox(height: 10),
                        _LabeledBlock(
                          title: '作成者',
                          icon: Icons.person,
                          child: event.createdByName.isEmpty
                              ? Text('—', style: text.bodyLarge)
                              : _personChip(
                                  event.createdByName,
                                  color,
                                  // ← 명시 색: 작성자는 iOS Blue 계열
                                  avatarBg: iosBlue.withValues(alpha: 0.18),
                                  avatarFg: iosBlue,
                                  chipBg: Colors.white,
                                  textColor: Colors.black87,
                                ),
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          height: 1, // 높이
                          thickness: 1, // 선 굵기
                          color: Colors.black12, // 색상
                        ),
                      ],

                      // 회의실 / 장비
                      if (event.equipments.isNotEmpty) ...[
                        SizedBox(height: 10),
                        _LabeledBlock(
                          title: '会議室 / 設備',
                          icon: Icons.meeting_room,
                          child: equipments.isEmpty
                              ? Text('—', style: text.bodyLarge)
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: equipments
                                      .map(
                                        (name) => Chip(
                                          label: Text(
                                            name,
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          labelPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 0,
                                              ),
                                          padding: EdgeInsets.zero,
                                          // side: BorderSide(color: color.outlineVariant, ),
                                          side: BorderSide(
                                            color: Colors.black38,
                                          ),
                                          // backgroundColor: color.surfaceContainerHighest
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          height: 1, // 높이
                          thickness: 1, // 선 굵기
                          color: Colors.black12, // 색상
                        ),
                      ],

                      // 참석자
                      if (attendees.isNotEmpty) ...[
                        SizedBox(height: 10),
                        _LabeledBlock(
                          title: '参加者',
                          icon: Icons.group,
                          child: attendees.isEmpty
                              ? Text('—', style: text.bodyLarge)
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: attendees
                                      .map(
                                        (n) => _personChip(
                                          n,
                                          color,
                                          avatarBg: Colors.greenAccent
                                              .withValues(alpha: 0.18),
                                          avatarFg: Colors.green,
                                          chipBg: Colors.white,
                                          textColor: Colors.black87,
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          height: 1, // 높이
                          thickness: 1, // 선 굵기
                          color: Colors.black12, // 색상
                        ),
                      ],

                      // 외부 URL
                      if (event.url != null) ...[
                        SizedBox(height: 10),
                        _LabeledBlock(
                          title: 'URL',
                          icon: Icons.link,
                          child: _buildUrlButton(context, event.url),
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          height: 1, // 높이
                          thickness: 1, // 선 굵기
                          color: Colors.black12, // 색상
                        ),
                      ],

                      // 장소
                      if (event.place != null) ...[
                        SizedBox(height: 10),
                        _LabeledBlock(
                          title: '場所',
                          icon: Icons.place,
                          child: Text(
                            (event.place?.trim().isEmpty ?? true)
                                ? '—'
                                : event.place!.trim(),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        const Divider(
                          height: 1, // 높이
                          thickness: 1, // 선 굵기
                          color: Colors.black12, // 색상
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ExpenseActionBarSection.calendarDeleteOnly(
        onDeletePressed: _onDeleteEvent,
        deleteConfirmMessage: '予定を削除しますか？',
        deleteText: '削　　　除',
        themeColor: iosBlue,
        padding: 8.0,
      ),
    );
  }

  // --- UI helpers -------------------------------------------------------------

  Widget _buildUrlButton(BuildContext context, String? raw) {
    final url = _normalizeUrl(raw);
    final color = Theme.of(context).colorScheme;
    if (url == null) {
      return Text('—', style: Theme.of(context).textTheme.bodyLarge);
    }
    return TextButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('링크를 열 수 없습니다.')));
        }
      },
      icon: Icon(
        Icons.open_in_new,
        size: 15,
        color: iosBlue.withValues(alpha: 1.0),
      ),
      label: Text(
        url,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: iosBlue.withValues(alpha: 1.0)),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        alignment: Alignment.centerLeft,
        foregroundColor: color.primary,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  static String? _normalizeUrl(String? u) {
    if (u == null) return null;
    final t = u.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }

  static DateTime _toJst(DateTime utc) =>
      utc.toUtc().add(const Duration(hours: 9));

  static String _formatRangeJst(DateTime s, DateTime e) {
    final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
    final wd = ['月', '火', '水', '木', '金', '土', '日']; // DateTime.weekday: 1=Mon
    String d(DateTime dt) =>
        '${dt.year}年${(dt.month)}月${(dt.day)}日 ${wd[dt.weekday - 1]}曜日';
    String hm(DateTime dt) {
      final m = dt.minute;
      return m == 0 ? '${dt.hour}時' : '${dt.hour}時${(m)}分';
    }

    String hmSub(DateTime dt) {
      final m = dt.minute;
      // 분이 0이면 '9時' 형태, 아니면 '9時5分'처럼 표시
      return m == 0 ? '${dt.hour}時' : '${dt.hour}時${(m)}分';
    }

    return sameDay
        ? '${d(s)}\n${hmSub(s)}から ${hmSub(e)}まで'
        : '${d(s)} ${hm(s)}から\n${d(e)} ${hm(e)}まで';
  }

  static String? _repeatDetail(CalendarSingle ev) {
    switch (ev.repeat) {
      case 'daily':
        return '毎日';
      case 'weekly':
      case 'biweekly':
        if (ev.repeatWeekdays.isEmpty) return '指定なし';
        final map = {1: '月', 2: '火', 3: '水', 4: '木', 5: '金', 6: '土', 7: '日'};
        final days = ev.repeatWeekdays.map((d) => map[d] ?? '$d').join('·');
        return (ev.repeat == 'biweekly') ? '隔週 ${days}曜日' : '毎週 ${days}曜日';
      case 'monthly':
        if (ev.repeatMonthDays.isEmpty) return '指定なし';
        final days = ev.repeatMonthDays.map((d) => '$d日').join('·');
        return '毎月 $days';
      case 'yearly':
        final m = ev.repeatYearMonth;
        final d = ev.repeatYearDay;
        if (m == null || d == null) return '指定なし';
        return '毎年 ${m}月 ${d}日';
      case 'custom':
        if (ev.customDates.isEmpty) return null;
        final preview = ev.customDates.take(3).join(', ');
        final more = ev.customDates.length > 3
            ? ' 외 ${ev.customDates.length - 3}건'
            : '';
        return '${preview}$more';
      default:
        return null;
    }
  }
}

class _RepeatInfo extends StatelessWidget {
  const _RepeatInfo({required this.ev});
  final CalendarSingle ev;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: iosLabel.withValues(alpha: 0.65),
    );

    // custom 이 아니면 _repeatDetail 결과 그대로 보여줌
    if (ev.repeat != 'custom') {
      final label = EventDetailPage._repeatDetail(ev);
      return Text('繰り返し：${label ?? 'なし'}', style: textStyle);
    }

    // custom 인 경우에만 날짜 목록(펼침) 표시
    return _RepeatCustomDates(dates: ev.customDates);
  }
}

class _RepeatCustomDates extends StatefulWidget {
  const _RepeatCustomDates({required this.dates});
  final List<String> dates;

  @override
  State<_RepeatCustomDates> createState() => _RepeatCustomDatesState();
}

class _RepeatCustomDatesState extends State<_RepeatCustomDates> {
  bool _expanded = false;

  String _format(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  DateTime? _tryParseUtc(String s) {
    // 1) 기존 parseUtc 시도
    final byUtil = parseUtc(s);
    if (byUtil != null) return byUtil.toUtc();

    // 2) DateTime.tryParse 보조 (날짜-only면 00:00Z로 가정)
    final byCore = DateTime.tryParse(s);
    if (byCore != null) {
      if (s.length == 10) {
        return DateTime.utc(byCore.year, byCore.month, byCore.day);
      }
      return byCore.toUtc();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: iosLabel.withValues(alpha: 0.65),
    );

    final parsed = widget.dates
        .map(_tryParseUtc)
        .whereType<DateTime>()
        .map(EventDetailPage._toJst)
        .toList()
      ..sort();

    if (parsed.isEmpty) {
      return Text('繰り返し：なし', style: textStyle);
    }

    final all = parsed.map(_format).toList();
    final preview = all.take(3).toList();
    final rest = all.length - preview.length;
    final showList = _expanded ? all : preview;
    final hasMore = !_expanded && rest > 0;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            const TextSpan(text: '繰り返し：'),
            TextSpan(text: showList.join('、')),
            if (hasMore) ...[
              TextSpan(text: ' 外$rest件 '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.expand_more, size: 16, color: textStyle?.color),
              ),
            ],
            if (_expanded)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.expand_less, size: 16, color: textStyle?.color),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _chip({
  required IconData icon,
  required String label,
  required Color background,
  required Color foreground,
}) {
  return Chip(
    avatar: Icon(icon, size: 16, color: foreground),
    label: Text(label),
    side: BorderSide.none,
    shape: const StadiumBorder(),
    backgroundColor: background,
    labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
    visualDensity: VisualDensity.compact,
  );
}

Widget _personChip(
  String name,
  ColorScheme color, {
  required Color avatarBg, // 원 배경색
  required Color avatarFg, // 원 글자색
  Color chipBg = Colors.white, // 칩 배경
  Color? textColor, // 이름 글자색(없으면 기본)
}) {
  final initial = name.isNotEmpty ? name.substring(0, 1) : '?';
  return Chip(
    label: Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: avatarBg,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: avatarFg,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor, // null이면 Theme 기본 사용
          ),
        ),
      ],
    ),
    backgroundColor: chipBg,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    labelPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    padding: EdgeInsets.zero,
    side: BorderSide.none,
    // 보더 제거
    shape: const StadiumBorder(), // 기본 모양
  );
}

class _LabeledBlock extends StatelessWidget {
  const _LabeledBlock({
    required this.title,
    required this.child,
    this.icon,
    this.indent = 5, // 내용 들여쓰기 간격
    this.spacing = 3, // 제목↔내용 간격
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final double indent;
  final double spacing;
  
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: child,
        ),
      ],
    );
  }
}
