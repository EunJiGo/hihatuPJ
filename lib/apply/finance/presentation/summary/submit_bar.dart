import 'package:flutter/material.dart';
import '../../../../utils/dialog/attention_dialog.dart';
import '../../../../utils/dialog/confirmation_dialog.dart';
import '../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/widgets/common_submit_buttons.dart';
import '../../../../utils/widgets/dropdown_option.dart';
import '../../../../utils/widgets/modals/dropdown_modal_widget.dart';
import '../../api/fetch_transportation_submit.dart';
import '../../domain/enums/apply_kind.dart';
import '../../state/transportation_view_model.dart';
import '../action/transportation_actions.dart';
import '../constants/apply_kind_option.dart';

class SubmitBar extends StatelessWidget {
  const SubmitBar({
    super.key,
    required this.vm,
    required this.currentMonth,
    required this.actions,
    required this.invalidateProvider,
  });

  final TransportationVM? vm;
  final DateTime currentMonth;
  final TransportationActions actions;
  final void Function(DateTime month) invalidateProvider;

  @override
  Widget build(BuildContext context) {
    final hasAny = vm?.hasAny ?? false;

    final all = hasAny
        ? [...vm!.commute, ...vm!.single, ...vm!.remoteList, ...vm!.others]
        : const [];

    // 데이터가 있고 항목도 있고, 모든 항목이 submitted 상태인지
    final isAllSubmitted =
        hasAny && all.isNotEmpty && all.every((e) => e.submissionStatus == 'submitted');

    return CommonSubmitButtons(
      saveText: '申　　請',
      submitText: '一括提出',
      padding: 0,
      themeColor: const Color(0xFF0253B3),
      submitConfirmMessage: null,
      // “제출 가능”일 때만 활성화
      // (로딩 아님 && 데이터 있음 && 아직 전부 제출 아님)
      activeSubmitButton: vm != null && hasAny && !isAllSubmitted,
      // 신청 버튼(네비게이션만) - 확인 다이얼로그 없음
      onSavePressed: () {
        if (vm == null) {
          attentionDialog(context, '注意', '読み込み中です。しばらくお待ちください。');
          return;
        }
        final kinds = ApplyKind.values;
        final options = kinds.map((k) {
          final (icon, color) = ApplyKindOption.iconOf(k);
          return DropdownOption.fromText(k.label, icon: icon, iconColor: color);
        }).toList();

        DropdownModalWidget.show(
          context: context,
          options: options,
          selectedValue: null,
          isSelectCircleIcon: false,
          onSelected: (label) async {
            final kind = kinds.firstWhere((k) => k.label == label);
            await actions.handleResult(actions.pushFor(kind));
          },
          selectedTextColor: const Color(0xFF1565C0),
          selectedIconColor: Colors.blueAccent,
          selectedBorderColor: const Color(0xFF64B5F6),
          selectedBackgroundColor: const Color(0xFFE3F2FD),
        );
      },
      // 일괄 제출 – 확인 다이얼로그는 내부에서!
      submitConfirmBuilder: (_) =>
      '${currentMonth.year}年${currentMonth.month}月の申請内訳を提出しますか？\n提出したら、修正ができないです。',

      onSubmitPressed: () async {
        if (vm == null) {
          attentionDialog(context, '注意', '読み込み中です。しばらくお待ちください。');
          return;
        }
        if (!hasAny) {
          attentionDialog(context, '注意', '申請内訳がありません。');
          return;
        }
        if (isAllSubmitted) { // 버튼이 비활성화되므로 보통 여기 안 옴(방어코드)
          attentionDialog(context, '注意', '既に申請内訳を全て提出しました。');
          return;
        }

        // 여기서는 "확인"이 끝났다고 가정하고 서버 호출만 수행
        final ok = await fetchTransportationSubmit('admins', currentMonth);
        if (ok) {
          await successDialog(
            context,
            '一括提出完了',
            '${currentMonth.year}年${currentMonth.month}月の申請内訳を一括提出しました。',
          );
          invalidateProvider(currentMonth);
          actions.afterInvalidate();
        } else {
          attentionDialog(
            context,
            'エラー',
            '${currentMonth.year}年${currentMonth.month}月の申請内訳の一括提出を失敗しました。',
          );
        }
      },
    );
  }
}
