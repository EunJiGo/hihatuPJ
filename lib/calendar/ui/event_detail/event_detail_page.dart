import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/ui/event_detail/utils/datetime_format.dart';
import 'package:hihatu_project/calendar/ui/event_detail/utils/timezone_to_jst.dart';
import '../../data/fetch_calendar_delete.dart';
import '../../domain/calendar_single.dart';
import '../../../../apply/finance/detail/summary/sections/action_bar_section.dart';
import '../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../../styles.dart';
import '../shared/header.dart';
import 'sections/header_card.dart';
import 'sections/info_blocks.dart';
import '../../../../utils/date/date_utils.dart'; // parseUtc

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.event, required this.pivotJst});
  final CalendarSingle event;
  final DateTime pivotJst;

  @override
  Widget build(BuildContext context) {
    final startUtc = parseUtc(event.start) ?? DateTime.now().toUtc();
    final endUtc   = parseUtc(event.end)   ?? startUtc.add(const Duration(minutes: 30));
    final jstStart = toJst(startUtc);
    final jstEnd   = toJst(endUtc);
    final period   = formatRangeJst(jstStart, jstEnd);
    final isSecret = event.isSecret == 1;

    Future<void> onDelete() async {
      _showLoadingDialog(context, message: '削除中…');
      try {
        final success = await fetchCalendarDelete(event.id);
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        if (!success) {
          await warningDialog(context, '削除に失敗しました', 'しばらくしてからもう一度お試しください。');
          return;
        }
        await successDialog(context, '削除しました', '予定を削除しました。');
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (_) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
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
          onTapEdit: () {},
          hideWeekdayLabels: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 제목/기간/반복/공개칩
              HeaderCard(event: event, period: period, isSecret: isSecret),

              const SizedBox(height: 12),

              // 상세 섹션들(현재 로직/디자인 그대로)
              InfoBlocks(event: event),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ExpenseActionBarSection.calendarDeleteOnly(
        onDeletePressed: onDelete,
        deleteConfirmMessage: '予定を削除しますか？',
        deleteText: '削　　　除',
        themeColor: iosBlue,
        padding: 8.0,
      ),
    );
  }
}

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