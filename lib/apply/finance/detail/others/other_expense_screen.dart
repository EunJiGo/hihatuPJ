import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/others/data/other_expense_detail_item.dart';
import 'package:hihatu_project/apply/finance/detail/others/sections/payment_recipient_section.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../base/base_main_screen.dart';
import '../../../../header/title_header.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../../api/fetch_image_upload.dart';
import '../../api/fetch_transportation_delete.dart';
import '../../api/fetch_transportation_save.dart';
import '../../data/dtos/transportation_save.dart';
import '../../data/dtos/transportation_update.dart';
import '../../presentation/constants/other_expense_purpose_options.dart';
import '../../state/transportation_provider.dart';
import '../summary/sections/action_bar_section.dart';
import '../summary/sections/purpose_section.dart';
import '../summary/sections/amount_section.dart';
import '../summary/sections/receipt_section.dart';
import '../summary/sections/start_date_section.dart';
import '../../../../utils/widgets/app_bar/basic_app_bar.dart';
import 'other_expense_detail.dart';

class OtherExpenseScreen extends ConsumerStatefulWidget {
  final int? otherExpenseId;
  final DateTime currentLocalDate;


  const OtherExpenseScreen({this.otherExpenseId, required this.currentLocalDate, super.key});

  @override
  ConsumerState<OtherExpenseScreen> createState() => _OtherExpenseScreenState();
}

class _OtherExpenseScreenState extends ConsumerState<OtherExpenseScreen> {
  final TextEditingController _paymentRecipientController =
      TextEditingController();
  final _costController = TextEditingController();
  final TextEditingController _customPurposeController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _cost;
  String _purpose = '食事代';
  String? _customPurpose;
  String? _imageName;
  File? _imageFile;
  String? _submissionStatus;

  bool _isSaving = false;

  Future<void> _handleSavePressed() async {
    FocusScope.of(context).unfocus();
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 이미지 업로드
      if (_imageFile != null) {
        final uploadedFileName = await fetchImageUpload('admins', _imageFile!);
        if (uploadedFileName == null) {
          attentionDialog(context, 'アップロード失敗', '画像アップロードに失敗しました。');
          return;
        }
        _imageName = uploadedFileName;
      }

      // payload 빌드 (기존 로직 그대로)
      final saveData = widget.otherExpenseId == null
          ? TransportationSave(
        date: _selectedDate,
        expenseType: 'travel',
        twice: false,
        amount: int.tryParse(
          _costController.text.trim(),
        ),
        payTo: _paymentRecipientController
            .text
            .trim(),
        goals: _purpose == 'その他'
            ? (_customPurpose ?? '')
            : _purpose,
        submissionStatus: 'draft',
        reviewStatus: '',
        id: widget.otherExpenseId,
      )
          : TransportationUpdate(
        date: _selectedDate,
        id: widget.otherExpenseId!,
        employeeId: "admins",
        // 임시
        expenseType: "travel",
        amount: int.tryParse(
          _costController.text.trim(),
        ),
        twice: false,
        payTo: _paymentRecipientController
            .text
            .trim(),
        goals: _purpose == 'その他'
            ? (_customPurpose ?? '')
            : _purpose,
        image: _imageName ?? '',
        submissionStatus: 'draft',
        reviewStatus: '',
      );

      final success = await fetchTransportationSaveUpload(
        widget.otherExpenseId == null ? (saveData as TransportationSave?) : null,
        widget.otherExpenseId != null ? (saveData as TransportationUpdate?) : null,
        widget.otherExpenseId == null,
      );

      if (success) {
        await successDialog(context, '保存完了', '立替金保存が完了しました。');
        if (mounted) Navigator.pop(context, _selectedDate);
      } else {
        attentionDialog(context, '保存エラー', '立替金保存に失敗しました.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDeletePressed() async {
    final id = widget.otherExpenseId;
    if (id == null) return;

    final success = await fetchTransportationDelete(id);
    if (success) {
      await successDialog(context, '削除完了', '立替金削除が完了しました。');
      if (mounted) Navigator.pop(context, _selectedDate);
    } else {
      warningDialog(context, 'エラー', '送信に失敗しました。');
    }
  }

  @override
  void initState() {
    super.initState();
    print('print(widget.currentLocalDate);');
    print(widget.currentLocalDate);
    print('print(widget.currentLocalDate);');
    final transportationId = widget.otherExpenseId;
    if (transportationId != null) {
      ref.read(transportationDetailProvider(transportationId).future).then((
        detail,
      ) {
        if (mounted) {
          setState(() {
            _paymentRecipientController.text = detail.payTo;
            _costController.text = detail.amount.toString();
            _selectedDate = DateTime.parse(detail.payDay);
            final isPresetTransport = otherExpensePurposeOptions.contains(
              detail.goals,
            );
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
    final otherExpenseId = widget.otherExpenseId;
    final detailAsync = otherExpenseId != null
        ? ref.watch(transportationDetailProvider(otherExpenseId))
        : null;

    final item = OtherExpenseDetailItem(
      createdAt: _selectedDate,
      paymentRecipient: _paymentRecipientController.text.trim(),
      totalFare: _cost ?? int.tryParse(_costController.text.trim()) ?? 0,
      purpose: _purpose == 'その他' ? (_customPurpose ?? '-') : _purpose,
      imageUrl: _imageName,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: BaseMainScreen(
        backgroundColor: Colors.white,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFEFF2F4),
          child: Column(
            children: [
                BasicAppBar(onBack: () {Navigator.pop(context, widget.currentLocalDate);},), // 커스텀 AppBar
              WelcomeHeader(
                title: otherExpenseId == null
                    ? '立替金申請'
                    : _submissionStatus == 'submitted'
                    ? '立替金申請完了'
                    : '立替金修正',
                subtitle: _submissionStatus == 'submitted'
                    ? '申請した立替金を確認してください。'
                    : '日付・目的・金額などを確認して申請しましょう。',
                titleFontSize: 18,
                subtitleFontSize: 12,
                imagePath: 'assets/images/tabbar/apply/apply.png',
                imageWidth: 60,
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (detailAsync?.isLoading == true) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (detailAsync?.hasError == true) {
                      return Center(
                        child: Text('データ取得エラー: ${detailAsync?.error}'),
                      );
                    }
                    return _submissionStatus == 'submitted'
                        ? otherExpenseBuildDetailBody(item)
                        : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StartDateSection(
                                title: '日付',
                                date: _selectedDate,
                                isReadOnly: false,
                                onPick: (d) =>
                                    setState(() => _selectedDate = d),
                              ),
                              const SizedBox(height: 28),

                              PaymentRecipientSection(
                                controller: _paymentRecipientController,
                                isDisabled: _submissionStatus == 'submitted',
                                onChanged: (val) {
                                  setState(() {
                                    _paymentRecipientController.text = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 22),

                              PurposeSection(
                                options: otherExpensePurposeOptions,
                                selectedPurpose: _purpose,
                                customPurposeController:
                                _customPurposeController,
                                isDisabled:
                                _submissionStatus == 'submitted',
                                onPurposeChanged: (val) {
                                  setState(() {
                                    _purpose = val;
                                    if (_purpose != 'その他') {
                                      _customPurpose = null;
                                      _customPurposeController.clear();
                                    }
                                  });
                                },
                                onCustomPurposeChanged: (val) {
                                  setState(() {
                                    _customPurpose = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 22),

                              AmountSection(
                                controller: _costController,
                                isDisabled:
                                _submissionStatus == 'submitted',
                                onChanged: (val) {
                                  setState(() {
                                    _cost = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 22),

                              ReceiptSection(
                                elementId: widget.otherExpenseId,
                                // null이면 신규, 값 있으면 수정 모드로 간주
                                isDisabled:
                                _submissionStatus == 'submitted',
                                imageFile: _imageFile,
                                // 신규일 때 선택된 파일 (없으면 null)
                                imageName: _imageName,
                                // 수정일 때 표시할 저장된 이름 (없으면 null)
                                onImageSelected: (path) {
                                  setState(() {
                                    _imageFile = File(path);
                                    _imageName = path.split('/').last;
                                  });
                                },
                              ),
                              const SizedBox(height: 36),

                              ExpenseActionBarSection.otherExpense(
                                onSavePressed: _handleSavePressed,
                                onDeletePressed: _handleDeletePressed,
                                canShowSave:
                                widget.otherExpenseId == null ||
                                    _submissionStatus == 'draft',
                                canShowDelete:
                                widget.otherExpenseId != null &&
                                    _submissionStatus == 'draft',
                              ),
                            ],
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
