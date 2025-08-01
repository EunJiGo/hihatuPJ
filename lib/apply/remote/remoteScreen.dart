import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/remote/widgets/remoteAllowanceRulesRadioColumn.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/form_label.dart';

import '../../utils/dialog/attention_dialog.dart';
import '../../utils/dialog/success_dialog.dart';
import '../../utils/dialog/warning_dialog.dart';
import '../../utils/widgets/common_submit_buttons.dart';
import '../transportations/summary/widgets/date_picker_button.dart';
import '../transportations/transportation/data/fetch_transportation_delete.dart';
import '../transportations/transportation/data/fetch_transportation_save.dart';
import '../transportations/transportation/domain/transportation_save.dart';
import '../transportations/transportation/domain/transportation_update.dart';
import '../transportations/transportation/state/transportation_provider.dart';
import '../transportations/transportation_screen.dart';
import 'domain/remoteAllowanceRules.dart';

class RemoteScreen extends ConsumerStatefulWidget {
  final int? transportationId;

  const RemoteScreen({this.transportationId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  int? transportationId;
  Map<String, dynamic> _remoteAllowanceRule = remoteAllowanceRules[0];
  int? _cost;
  String? _submissionStatus;


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
    transportationId = widget.transportationId;
    if (transportationId != null) {
      ref.read(transportationDetailProvider(transportationId!).future).then((
          detail,
          ) {
        if (mounted) {
          setState(() {
            _submissionStatus = detail.submissionStatus;

            // _remoteAllowanceRule = detail.amount;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime _selectedDate = DateTime.now();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // SafeArea로 상태바 높이 처리 + 흰 배경
          const SafeArea(
            bottom: false,
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(height: 0), // 그냥 상태바 영역만 확보
            ),
          ),

          // 커스텀 AppBar
          Container(
            height: kToolbarHeight, // 기본 AppBar의 높이를 나타내는 상수
            decoration: BoxDecoration(
              color: Color(0xFFfeaaa9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0), // 왼쪽 위는 직각
                topRight: Radius.circular(0), // 오른쪽 위는 직각
                bottomLeft: Radius.circular(20), // 왼쪽 아래만 둥글게
                bottomRight: Radius.circular(20), // 오른쪽 아래만 둥글게
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ✅ 가운데 제목
                const Text(
                  '在宅勤務手当',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                // ✅ 왼쪽 뒤로가기 버튼
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black, // 아이콘 색
                  ),
                ),
              ],
            ),
          ),

          // 본문
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          FormLabel(
                            text: '日付',
                            icon: Icons.calendar_today,
                            iconColor: Color(0xFFfeaaa9),
                          ),
                          Center(
                            child: DatePickerButton(
                              date: _selectedDate,
                              isFullDate: false,
                              backgroundColor: Colors.white,
                              // 비활성화 스타일
                              borderRadius: 20,
                              shadowColor: const Color(0xFF8e8e8e),
                              onPick: () async {
                                return _selectedDate; // 그냥 현재 날짜 리턴, 아무것도 안 바꿈
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormLabel(
                            text: '在宅勤務日数',
                            icon: Icons.home_work,
                            iconColor: Color(0xFFfeaaa9),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              // border: Border.all(
                              //   color: Colors.grey, // 테두리 색상
                              //   width: 1.0, // 테두리 두께
                              // ),
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
                              isDisabled: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 36),
                    child: CommonSubmitButtons(
                      // 보존
                      onSavePressed: () async {
                        if (widget.transportationId == null) {
                          // && submissionStatus != 'submitted'
                          final saveData = TransportationSave(
                            date: _selectedDate,
                            expenseType: 'home_office_expenses',
                            twice: false,
                            amount: _remoteAllowanceRule['amount'],
                            submissionStatus: 'draft',
                            reviewStatus: '', // 보존은 null
                            id: widget.transportationId!,
                          );
                          final success = await fetchTransportationSaveUpload(
                            saveData as TransportationSave?,
                            null,
                            true,
                          );
                          if (success) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransportationScreen(),
                              ),
                                  (route) => false,
                            );
                          } else {
                            warningDialog(
                              context,
                              '保存エラー',
                              '交通費保存に失敗しました。',
                            );
                          }
                        } else {
                          final saveData = TransportationUpdate(
                            date: _selectedDate,
                            expenseType: 'home_office_expenses',
                            twice: false,
                            amount: _remoteAllowanceRule['amount'],
                            submissionStatus: 'draft',
                            reviewStatus: '', // 보존은 null
                            id: widget.transportationId!,
                            employeeId: 'admins',
                          );
                          final success = await fetchTransportationSaveUpload(
                            null,
                            saveData,
                            true,
                          );
                          if (success) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransportationScreen(),
                              ),
                                  (route) => false,
                            );
                          } else {
                            warningDialog(
                              context,
                              '修正エラー',
                              '交通費修正に失敗しました。',
                            );
                          }
                        }
                      },

                      // 삭제
                      onSubmitPressed:
                      widget.transportationId != null
                          ? () async {
                        final success =
                        await fetchTransportationDelete(
                          widget.transportationId!,
                        );
                        if (success) {
                          await successDialog(
                            context,
                            '削除完了',
                            '交通費削除が完了しました。',
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const TransportationScreen(),
                            ),
                                (route) => false,
                          );
                        } else {
                          warningDialog(context, 'エラー',
                              '送信に失敗しました。');
                        }
                      }
                          : () {},

                      // 🧑‍🎨 옵션 설정 (텍스트/색상)
                      submitText: '削　　除',
                      saveConfirmMessage: '交通費を保存しますか？',
                      submitConfirmMessage: '交通費を削除しますか？',
                      showSubmitButton:
                      widget.transportationId != null &&
                          _submissionStatus == 'draft',
                      showSaveButton:
                      widget.transportationId == null ||
                          _submissionStatus == 'draft',
                      // ← 조건부로 삭제 버튼 숨김
                      themeColor: const Color(0xFFfe6966),
                      padding: 0.0, // 원하는 색상
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
