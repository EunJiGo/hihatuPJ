import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/others/widgets/other_expense_drop_down.dart';
import 'package:hihatu_project/apply/others/widgets/other_expense_textField.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_image_upload.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/form_label.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_update.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../../../../utils/widgets/common_submit_buttons.dart';
import '../transportations/summary/widgets/calendar_screen.dart';
import '../transportations/summary/widgets/date_picker_button.dart';
import '../transportations/transportation/data/fetch_image_upload.dart';
import '../transportations/transportation/data/fetch_transportation_delete.dart';
import '../transportations/transportation/data/fetch_transportation_save.dart';
import '../transportations/transportation/domain/transportation_save.dart';
import '../transportations/transportation/presentation/detail/widgets/transportation_image_upload.dart';
import '../transportations/transportation/state/transportation_provider.dart';
import 'domain/other_expense_purpose.dart';

class OtherExpenseScreen extends ConsumerStatefulWidget {
  final int? transportationId;

  const OtherExpenseScreen({this.transportationId, super.key});

  @override
  ConsumerState<OtherExpenseScreen> createState() => _OtherExpenseScreenState();
}

class _OtherExpenseScreenState extends ConsumerState<OtherExpenseScreen> {
  final TextEditingController _paymentRecipientController = TextEditingController();
  final _costController = TextEditingController();
  final TextEditingController _customPurposeController = TextEditingController();

  // _purpose

  DateTime _selectedDate = DateTime.now();

  String _paymentRecipient = '';
  int? _cost;
  String _purpose = '食事代';
  String? _customPurpose;
  String? _imageName;
  File? _imageFile;
  String? _submissionStatus;


  @override
  void initState() {
    super.initState();

    final transportationId = widget.transportationId;
    print('transportationId');
    print('transportationId');
    print('transportationId');
    print(transportationId);

    if (transportationId != null) {
      ref.read(transportationDetailProvider(transportationId).future).then((
          detail,
          ) {
        if (mounted) {
          setState(() {
            _paymentRecipientController.text = detail.payTo;
            _costController.text = detail.amount.toString();
            _selectedDate = DateTime.parse(detail.payDay);
            final isPresetTransport = otherExpensePurposeOptions.contains(detail.goals);

            if (isPresetTransport) {
              _purpose = detail.goals;
              _customPurpose = null;
            } else {
              _purpose = 'その他'; // 드롭다운에 표시
              _customPurpose = detail.goals; // 입력 필드에 표시할 사용자 정의 값
              _customPurposeController.text = detail.goals;
            }
            _imageName = detail.image;
            _submissionStatus = detail.submissionStatus;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // transportationId가 있을 때만 provider 호출
    final commuteIdInt = widget.transportationId;
    final detailAsync =
    commuteIdInt != null
        ? ref.watch(transportationDetailProvider(commuteIdInt))
        : null;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                '立替金申請',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3d3d3d),
                  // color: Colors.teal,
                ),
              ),
              backgroundColor: Color(0xFF89e6f4),
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            body: Builder(
              builder: (context) {
                if (detailAsync?.isLoading == true) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (detailAsync?.hasError == true) {
                  return Center(child: Text('データ取得エラー: ${detailAsync?.error}'));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(
                        text: '日付',
                        icon: Icons.calendar_today,
                        iconColor: Color(0xFF89e6f4),
                      ),
                      Center(
                        child: _submissionStatus == "submitted"
                            ? DatePickerButton(
                          date: _selectedDate,
                          isFullDate: true,
                          backgroundColor: Colors.grey.shade200, // 비활성화 스타일
                          borderRadius: 20,
                          shadowColor: const Color(0xFF8e8e8e),
                          onPick: () async {
                            return _selectedDate; // 그냥 현재 날짜 리턴, 아무것도 안 바꿈
                          },
                        )
                            :DatePickerButton(
                          date: _selectedDate,
                          isFullDate: true,
                          backgroundColor: Colors.white,
                          borderRadius: 20,
                          shadowColor: const Color(0xFF8e8e8e),
                          onPick:  () async {
                            FocusManager.instance.primaryFocus?.unfocus();

                            final picked = await Navigator.push<DateTime>(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CalendarScreen(
                                  selectedDay: _selectedDate,
                                ),
                              ),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                            return picked;
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      FormLabel(
                        text: '支払先',
                        icon: Icons.payments,
                        iconColor: Color(0xFF89e6f4),
                      ),
                      OtherExpenseTextField(
                        answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                        controller: _paymentRecipientController,
                        onChanged: (val) {
                          setState(() {
                            _paymentRecipient = val;
                          });
                        },
                        hintText: '例）山田太郎、○○株式会社',
                      ),
                      const SizedBox(height: 28),


                      FormLabel(
                        text: '目的',
                        icon: Icons.flag,
                        iconColor: Color(0xFF89e6f4),
                      ),
                      OtherExpenseDropDown(
                        options: otherExpensePurposeOptions,
                        answerStatus: _submissionStatus == 'submitted' ? 1 : 0, // 비활성화면 1 넣기
                        selectedValue: otherExpensePurposeOptions.contains(_purpose) ? _purpose : 'その他',
                        onChanged: (val) {
                          setState(() {
                            _purpose = val ?? '';
                            _customPurpose = null;

                            if (_purpose != 'その他') {
                              _customPurposeController.clear();
                            }
                          });
                        },
                      ),

                      if (_purpose == 'その他') ...[
                        const SizedBox(height: 12),
                        OtherExpenseTextField(
                          answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                          controller: _customPurposeController,
                          initialAnswer: _customPurpose,
                          onChanged: (val) {
                            setState(() {
                              _customPurpose = val;
                            });
                          },
                          hintText: '交通手段を入力してください。',
                        ),
                      ],
                      const SizedBox(height: 22),

                      FormLabel(
                        text: '金額 (\u5186)',
                        icon: Icons.attach_money,
                        iconColor: Color(0xFF89e6f4),
                      ),
                      OtherExpenseTextField(
                        answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                        controller: _costController,
                        // initialAnswer: _cost,
                        onChanged: (val) {
                          setState(() {
                            _cost = int.tryParse(val);
                          });
                        },
                        hintText: '金額を入力してください',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      const SizedBox(height: 22),

                      FormLabel(
                        text: '領収書/チケット添付',
                        icon: Icons.receipt_long,
                        iconColor: Color(0xFF89e6f4),
                      ),

                      // 이미 저장된 걸 가지고 옴
                      if (commuteIdInt != null) ...[
                        CommuterImageUpload(
                          focusNode: FocusNode(),
                          imagePath: _imageName,
                          themeColor: const Color(0xFF89e6f4),
                          shadowColor: const Color(0x2281C784),
                          isDisabled: _submissionStatus == 'submitted' ? true : false, // 업로드 활성화 -- 이상
                          onImageSelected: (path) {
                            setState(() {
                              _imageFile = File(path);
                              _imageName = path.split('/').last;
                            });
                          },
                        ),
                      ],

                      if (commuteIdInt == null) ...[
                        TransportationImageUpload(
                          focusNode: FocusNode(),
                          imagePath: _imageFile?.path,
                          themeColor: const Color(0xFF89e6f4),
                          onImageSelected: (path) {
                            setState(() {
                              _imageFile = File(path);
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 36),

                      // ✅ 하단 버튼 영역
                      CommonSubmitButtons(
                        // 보존
                        onSavePressed: () async {
                          print('🔁 onSavePressed triggered');
                          FocusScope.of(context).unfocus();

                          print('선택한 파일 경로: ${_imageFile?.path}');

                          if (_imageFile != null) {
                            final uploadedFileName = await fetchImageUpload(
                              'admins',
                              _imageFile!,
                            );
                            if (uploadedFileName == null) {
                              attentionDialog(
                                context,
                                'アップロード失敗',
                                '画像アップロードに失敗しました。',
                              );
                              return;
                            }
                            _imageName = uploadedFileName; // 서버에서 받은 이미지 파일명 저장
                            print(_imageName);
                          }

                          final saveData =
                          widget.transportationId == null
                              ? TransportationSave(
                            date: _selectedDate,
                            expenseType: 'travel',
                            twice: false,
                            amount: int.tryParse(
                              _costController.text.trim(),
                            ),
                            payTo: _paymentRecipientController.text.trim(),
                            goals: _purpose == 'その他'
                                ? (_customPurpose ?? '')
                                : _purpose,
                            image: _imageName ?? '',
                            submissionStatus: 'draft',
                            // ✅ 보존은 null
                            reviewStatus: '',
                            id: widget.transportationId,
                          )
                              : TransportationUpdate(
                            date: _selectedDate,
                            id: widget.transportationId!,
                            employeeId: "admins",
                            // 임시
                            expenseType: "travel",
                            amount: int.tryParse(
                              _costController.text.trim(),
                            ),
                            twice: false,
                            payTo: _paymentRecipientController.text.trim(),
                            goals: _purpose == 'その他'
                                ? (_customPurpose ?? '')
                                : _purpose,
                            image: _imageName ?? '',
                            submissionStatus: 'draft',
                            reviewStatus: '',
                          );

                          if (widget.transportationId == null) {
                            final success = await fetchTransportationSaveUpload(
                              saveData as TransportationSave?,
                              null,
                              true,
                            );

                            if (success) {
                              print('_imageFile : ${_imageFile}');
                              await successDialog(
                                context,
                                '保存完了',
                                '交通費保存が完了しました。',
                              );
                              Navigator.pop(context, _selectedDate);
                            } else {
                              attentionDialog(
                                context,
                                '保存エラー',
                                '交通費保存に失敗しました。',
                              );
                            }
                          } else {
                            final success = await fetchTransportationSaveUpload(
                              null,
                              saveData as TransportationUpdate?,
                              false,
                            );
                            if (success) {
                              print('_imageFile : ${_imageFile}');
                              await successDialog(
                                context,
                                '保存完了',
                                '交通費保存が完了しました。',
                              );
                              print('_selectedDate');
                              print('_selectedDate');
                              print('_selectedDate');
                              print(_selectedDate);
                              Navigator.pop(context, _selectedDate);
                            } else {
                              warningDialog(context, 'エラー', '交通費保存に失敗しました。');
                            }
                          }
                        },

                        // 삭제
                        onSubmitPressed:
                        widget.transportationId != null
                            ? () async {
                          final success =
                          await fetchTransportationDelete(
                            commuteIdInt!,
                          );
                          if (success) {
                            await successDialog(
                              context,
                              '削除完了',
                              '交通費削除が完了しました。',
                            );
                            Navigator.pop(context, _selectedDate);
                          } else {
                            warningDialog(context, 'エラー', '送信に失敗しました。');
                          }
                        }
                            : () {},

                        // 🧑‍🎨 옵션 설정 (텍스트/색상)
                        submitText: '削　　除',
                        saveConfirmMessage: '交通費を保存しますか？',
                        submitConfirmMessage: '交通費を削除しますか？',
                        showSubmitButton: widget.transportationId != null && _submissionStatus == 'draft',
                        showSaveButton: widget.transportationId == null || _submissionStatus == 'draft' ,
                        // ← 조건부로 삭제 버튼 숨김
                        themeColor: Color(0xFF008ac1),
                        padding: 0.0, // 원하는 색상
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
