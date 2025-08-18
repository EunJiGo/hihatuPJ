import 'package:flutter/material.dart';
import '../../../../utils/dialog/attention_dialog.dart';
import '../../../../utils/dialog/confirmation_dialog.dart';
import '../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/widgets/common_submit_buttons.dart';
import '../../../../utils/widgets/dropdown_option.dart';
import '../../../../utils/widgets/modals/dropdown_modal_widget.dart';
import '../../../apply_kind.dart';
import '../../../apply_kind_option.dart';
import '../../transportation/state/transportation_view_model.dart';
import '../../transportation/state/transportation_provider.dart';
import '../../transportation/data/fetch_transportation_submit.dart';
import '../transportation_actions.dart';

class SubmitBar extends StatelessWidget {
  const SubmitBar({
    super.key,
    required this.vm,
    required this.currentMonth,
    required this.actions,
    required this.invalidateProvider,
  });

  final TransportationVM vm;
  final DateTime currentMonth;
  final TransportationActions actions;
  final void Function(DateTime month) invalidateProvider;

  @override
  Widget build(BuildContext context) {
    return CommonSubmitButtons(
      saveText: '申　請',
      submitText: '一括提出',
      padding: 0,
      themeColor: const Color(0xFF0253B3),
      submitConfirmMessage: null,

      onSavePressed: () {
        final kinds = ApplyKind.values;
        final options = kinds.map((k) {
          final (icon, color) = ApplyKindOption.iconOf(k);
          return DropdownOption.fromText(k.label, icon: icon, iconColor: color);
        }).toList();

        DropdownModalWidget.show(
          context: context,
          options: options,
          selectedValue: null,
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

      onSubmitPressed: () async {
        if (!vm.hasAny) {
          attentionDialog(context, '注意', '申請内訳がありません。');
          return;
        }

        final all = [...vm.commute, ...vm.single, ...vm.remoteList, ...vm.others];
        final isAllSubmitted = all.every((e) => e.submissionStatus == 'submitted');
        if (isAllSubmitted) {
          attentionDialog(context, '注意', '既に申請内訳を全て提出しました。');
          return;
        }

        final confirmed = await ConfirmationDialog.show(
          context,
          message: '${currentMonth.year}年${currentMonth.month}月の申請内訳を提出しますか？\n提出したら、修正ができないです。',
        );
        if (confirmed != true) return;

        final ok = await fetchTransportationSubmit('admins', currentMonth);
        if (ok) {
          await successDialog(
            context, '一括提出完了',
            '${currentMonth.year}年${currentMonth.month}月の申請内訳を一括提出しました。',
          );
          invalidateProvider(currentMonth);
          actions.afterInvalidate();
        } else {
          attentionDialog(context, 'エラー',
              '${currentMonth.year}年${currentMonth.month}月の申請内訳の一括提出を失敗しました。');
        }
      },
    );
  }
}

