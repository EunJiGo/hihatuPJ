import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/remote/remote_detail.dart';
import 'package:hihatu_project/apply/finance/detail/remote/widgets/remote_allowance_rules_radio_column.dart';
import 'package:hihatu_project/apply/finance/presentation/summary/show_year_month_picker.dart';

import '../../../../base/base_main_screen.dart';
import '../../../../header/title_header.dart';
import '../../../../utils/dialog/attention_dialog.dart';
import '../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../../../../utils/widgets/common_submit_buttons.dart';
import '../../api/fetch_transportation_delete.dart';
import '../../api/fetch_transportation_save.dart';
import '../../data/dtos/transportation_save.dart';
import '../../data/dtos/transportation_update.dart';
import '../../domain/policies/remote_allowanceRules.dart';
import '../../presentation/widgets/date_picker_button.dart';
import '../../presentation/widgets/form_label.dart';
import '../../state/transportation_provider.dart';
import '../summary/sections/action_bar_section.dart';
import '../../../../utils/widgets/app_bar/basic_app_bar.dart';
import 'data/remote_detail_item.dart';

class RemoteScreen extends ConsumerStatefulWidget {
  final int? remoteId;
  final DateTime currentLocalDate;

  const RemoteScreen({this.remoteId, required this.currentLocalDate, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  int? transportationId;
  Map<String, dynamic> _remoteAllowanceRule = remoteAllowanceRules[0];
  int? _cost;
  String? _submissionStatus;
  int? _year;
  int? _month;
  DateTime _selectedDate = DateTime.now();
  bool isRemoteExists = false;
  bool _isSaving = false;

  Future<void> _handleSavePressed() async {
    FocusScope.of(context).unfocus();
    if (_isSaving) return;
    setState(() => _isSaving = true);

    if (widget.remoteId == null && isRemoteExists) {
      warningDialog(context, 'エラー', 'この月には在宅勤務手当はすでに申請済みです。');
    }

    try {
      // payload 빌드 (기존 로직 그대로)
      final saveData = widget.remoteId == null
          ? TransportationSave(
              date: _selectedDate,
              expenseType: 'home_office_expenses',
              twice: false,
              amount: _remoteAllowanceRule['amount'],
              submissionStatus: 'draft',
              reviewStatus: '',
              id: widget.remoteId,
            )
          : TransportationUpdate(
              date: _selectedDate,
              id: widget.remoteId!,
              employeeId: "admins",
              expenseType: "home_office_expenses",
              amount: _remoteAllowanceRule['amount'],
              twice: false,
              submissionStatus: 'draft',
              reviewStatus: '',
            );

      final success = await fetchTransportationSaveUpload(
        widget.remoteId == null ? (saveData as TransportationSave?) : null,
        widget.remoteId != null ? (saveData as TransportationUpdate?) : null,
        widget.remoteId == null,
      );

      if (success) {
        await successDialog(context, '保存完了', '在宅勤務手当の保存が完了しました。');
        if (mounted) Navigator.pop(context, _selectedDate);
      } else {
        attentionDialog(context, '保存エラー', '在宅勤務手当の保存に失敗しました.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDeletePressed() async {
    final id = widget.remoteId;
    if (id == null) return;

    final success = await fetchTransportationDelete(id);
    if (success) {
      await successDialog(context, '削除完了', '定期券削除が完了しました。');
      if (mounted) Navigator.pop(context, _selectedDate);
    } else {
      warningDialog(context, 'エラー', '送信に失敗しました。');
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 상태바 배경 투명
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
      ),
    );

    transportationId = widget.remoteId;
    if (transportationId != null) {
      ref.read(transportationDetailProvider(transportationId!).future).then((
        detail,
      ) {
        if (mounted) {
          setState(() {
            _submissionStatus = detail.submissionStatus;
            _year = detail.year;
            _month = detail.month;
            _selectedDate = DateTime(detail.year, detail.month, 1);
            _remoteAllowanceRule = remoteAllowanceRules.firstWhere(
              (rule) => rule['amount'] == detail.amount,
              orElse: () => remoteAllowanceRules[0], //기본값
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transportationAsync = ref.watch(
      transportationProvider(_selectedDate),
    );

    if (transportationAsync.hasValue) {
      final items = transportationAsync.value!;
      isRemoteExists = items.any(
        (item) => item.expenseType == 'home_office_expenses',
      );
    }

    final item = RemoteDetailItem(
      createdAt: _selectedDate,
      remoteAllowanceRule: _remoteAllowanceRule,
    );

    return BaseMainScreen(
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFEFF2F4),
        child: Column(
          children: [
            BasicAppBar(onBack: () {Navigator.pop(context, widget.currentLocalDate);},), // 커스텀 AppBar
            WelcomeHeader(
              title: widget.remoteId == null
                  ? '在宅勤務手当申請'
                  : _submissionStatus == 'submitted'
                  ? '在宅勤務手当申請完了'
                  : '在宅勤務手当修正',
              subtitle: _submissionStatus == 'submitted'
                  ? '申請した在宅勤務手当を確認してください。'
                  : '日付・在宅勤務日数・手当を確認して申請しましょう。',
              titleFontSize: 18,
              subtitleFontSize: 12,
              imagePath: 'assets/images/tabbar/apply/apply.png',
              imageWidth: 60,
            ),
            // 본문
            Expanded(
              child: _submissionStatus == 'submitted'
                  ? remoteBuildDetailBody(item)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          FormLabel(
                            text: '日付',
                            icon: Icons.calendar_today,
                            iconColor: Color(0xFF0253B3),
                          ),
                          Center(
                            child: DatePickerButton(
                              date: _selectedDate,
                              isFullDate: false,
                              backgroundColor: _submissionStatus == 'submitted'
                                  ? Colors.grey.shade200
                                  : Colors.white,
                              // 비활성화 스타일
                              borderRadius: 20,
                              shadowColor: const Color(0xFF8e8e8e),
                              onPick: _submissionStatus == 'submitted'
                                  ? () async {
                                      return _selectedDate; // 그냥 현재 날짜 리턴, 아무것도 안 바꿈
                                    }
                                  : () async {
                                      final picked = await showYearMonthPicker(
                                        context,
                                        _selectedDate.year,
                                        _selectedDate.month,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate = picked;
                                        });
                                      }
                                      return picked ?? _selectedDate;
                                    },
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormLabel(
                            text: '在宅勤務日数',
                            icon: Icons.home_work,
                            iconColor: Color(0xFF0253B3),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: RemoteAllowanceRulesRadioColumn(
                              value: _remoteAllowanceRule,
                              onChanged: (rule) {
                                setState(() {
                                  _remoteAllowanceRule = rule;
                                });
                              },
                              isDisabled: _submissionStatus == 'submitted'
                                  ? true
                                  : false,
                              inactiveColor: Color(0xFF6b6b6b),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: ExpenseActionBarSection.remote(
                onSavePressed: _handleSavePressed,
                onDeletePressed: _handleDeletePressed,
                canShowSave:
                    widget.remoteId == null || _submissionStatus == 'draft',
                canShowDelete:
                    widget.remoteId != null && _submissionStatus == 'draft',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
