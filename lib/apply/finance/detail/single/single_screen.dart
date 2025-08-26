import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/single/single_detail.dart';
import 'package:hihatu_project/apply/finance/detail/single/widgets/transportation_image_upload.dart';
import 'dart:io';
import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../../utils/dialog/warning_dialog.dart';
import '../../../../../utils/widgets/common_submit_buttons.dart';
import '../../../../base/base_main_screen.dart';
import '../../../../header/title_header.dart';
import '../../api/fetch_image_upload.dart';
import '../../api/fetch_transportation_delete.dart';
import '../../api/fetch_transportation_save.dart';
import '../../data/dtos/transportation_save.dart';
import '../../data/dtos/transportation_update.dart';
import '../../presentation/constants/transportation_purpose_options.dart';
import '../../presentation/constants/single_transport_options.dart';
import '../../presentation/screens/calendar_screen.dart';
import '../../presentation/widgets/date_picker_button.dart';
import '../../presentation/widgets/form_label.dart';
import '../../state/transportation_provider.dart';
import '../commuter/sections/amount_section.dart';
import '../commuter/sections/receipt_section.dart';
import '../commuter/sections/start_date_section.dart';
import '../commuter/sections/stations_section.dart';
import '../commuter/sections/transport_section.dart';
import '../summary/widgets/basic_app_bar.dart';
import '../commuter/widgets/commuter_image_upload.dart';
import 'data/single_detail_item.dart';
import 'widgets/transportation_drop_down.dart';
import 'widgets/transportation_text_field.dart';

class TransportationInputScreen extends ConsumerStatefulWidget {
  final int? singleId;

  const TransportationInputScreen({this.singleId, super.key});

  @override
  ConsumerState<TransportationInputScreen> createState() =>
      _TransportationInputScreenState();
}

class _TransportationInputScreenState
    extends ConsumerState<TransportationInputScreen> {
  final TextEditingController _departureController = TextEditingController();
  final FocusNode _departureFocusNode = FocusNode();

  final TextEditingController _arrivalController = TextEditingController();
  final FocusNode _arrivalFocusNode = FocusNode();

  //_customTransport
  final TextEditingController _customTransportController =
      TextEditingController();

  // _purpose
  final TextEditingController _customPurposeController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String _departure = '';
  String _arrival = '';
  String _transport = '電車';
  String? _customTransport;
  bool _roundTrip = false;
  String _purpose = '通勤';
  String? _customPurpose;
  final _costController = TextEditingController();
  int? _cost;
  String? _imageName;
  File? _imageFile;
  String? _submissionStatus;

  @override
  void initState() {
    super.initState();
    final transportationId = widget.singleId;
    print('initState transportationId $transportationId');
    if (transportationId != null) {
      ref.read(transportationDetailProvider(transportationId).future).then((
        detail,
      ) {
        if (mounted) {
          setState(() {
            _departureController.text = detail.fromStation;
            _arrivalController.text = detail.toStation;
            _costController.text = detail.amount.toString();
            _selectedDate =
                DateTime.tryParse(detail.durationStart) ??
                DateTime.now(); //durationStart: 정기권시작일

            final isPresetTransport = singleTransportOptions.contains(
              detail.railwayName,
            );
            if (isPresetTransport) {
              _transport = detail.railwayName;
              _customTransport = null;
            } else {
              _transport = 'その他'; // 드롭다운에 표시
              _customTransport = detail.railwayName; // 입력 필드에 표시할 사용자 정의 값
              _customTransportController.text = detail.railwayName;
            }

            final isPresetPurpose = transportationPurposeOptions.contains(
              detail.goals,
            );
            if (isPresetPurpose) {
              _purpose = detail.goals;
              _customPurpose = null;
            } else {
              _purpose = 'その他'; // 드롭다운에 표시
              _customPurpose = detail.goals; // 입력 필드에 표시할 사용자 정의 값
              _customPurposeController.text = detail.goals;
            }

            _imageName = detail.image;
            _submissionStatus = detail.submissionStatus;

            // 추가된 상태 업데이트 (CommuterScreen 스타일)
            _departure = detail.fromStation;
            _arrival = detail.toStation;
            _cost = detail.amount;
            _roundTrip = detail.twice;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // commuteId가 있을 때만 provider 호출
    final transportationId = widget.singleId;
    final detailAsync = transportationId != null
        ? ref.watch(transportationDetailProvider(transportationId))
        : null;

    final item = SingleDetailItem(
      createdAt: _selectedDate,
      departureStation: _departure,
      arrivalStation: _arrival,
      roundTrip: _roundTrip,
      transportMode: _transport == 'その他'
          ? (_customTransport ?? '-')
          : _transport,
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
              const BasicAppBar(), // 커스텀 AppBar
              WelcomeHeader(
                title: transportationId == null
                    ? '交通費申請'
                    : _submissionStatus == 'submitted'
                    ? '交通費申請完了'
                    : '交通費修正',
                subtitle: _submissionStatus == 'submitted'
                    ? '申請した交通費を確認してください。'
                    : '出発駅・到着駅・金額を確認して申請しましょう。',
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
                        ? singleBuildDetailBody(item)
                        : Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                36,
                              ),
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

                                  StationsSection(
                                    submissionLocked: false,
                                    departureCtrl: _departureController,
                                    arrivalCtrl: _arrivalController,
                                    isCommuter: false,
                                    hasVia: false,
                                    viaCtrls: [],
                                    onToggleVia: (v) => (){},
                                    onAddVia: () {},
                                    onRemoveVia: () {},
                                  ),
                                  const SizedBox(height: 22),

                                  // 왕복
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    // 변경
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        size: 16,
                                        color: _submissionStatus == 'submitted'
                                            ? Colors.black26
                                            : _roundTrip
                                            ? Color(0xFFf35a01)
                                            : Colors.grey,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        _roundTrip ? '往復あり' : '往復なし',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color:
                                              _submissionStatus == 'submitted'
                                              ? Colors.black26
                                              : _roundTrip
                                              ? Color(0xFFf35a01)
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Transform.translate(
                                        offset: const Offset(
                                          0,
                                          -2,
                                        ), // 위로 약간 이동시킴
                                        child: Transform.scale(
                                          // 스위치 크기 조절 위함
                                          scale: 0.8, // 크기를 80%로 줄임 (1.0이 기본)
                                          child: Switch.adaptive(
                                            value: _roundTrip,
                                            onChanged:
                                                _submissionStatus == 'submitted'
                                                ? null
                                                : (val) {
                                                    setState(
                                                      () => _roundTrip = val,
                                                    );
                                                  },
                                            activeColor:
                                                _submissionStatus == 'submitted'
                                                ? Colors.black45
                                                : Color(0xFFf35a01),
                                            // inactiveThumbColor:
                                            //     _submissionStatus == 'submitted'
                                            //         ? Colors.black26
                                            //         : Colors.black45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 22),

                                  TransportSection(
                                    options: singleTransportOptions,
                                    selectedTransport: _transport,
                                    customTransportController:
                                    _customTransportController,
                                    isDisabled: _submissionStatus == 'submitted',
                                    onTransportChanged: (val) {
                                      setState(() {
                                        _transport = val;
                                        if (_transport != 'その他') {
                                          _customTransport = null;
                                          _customTransportController.clear();
                                        }
                                      });
                                    },
                                    onCustomTransportChanged: (val) {
                                      setState(() {
                                        _customTransport = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  AmountSection(
                                    controller: _costController,
                                    isDisabled: _submissionStatus == 'submitted',
                                    onChanged: (val) {
                                      setState(() {
                                        _cost = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  FormLabel(
                                    text: '目的',
                                    icon: Icons.flag,
                                    iconColor: Color(0xFFFFB74D),
                                  ),
                                  TransportationDropDown(
                                    options: transportationPurposeOptions,
                                    answerStatus:
                                        _submissionStatus == 'submitted'
                                        ? 1
                                        : 0, // 비활성화면 1 넣기
                                    selectedValue:
                                        transportationPurposeOptions.contains(
                                          _purpose,
                                        )
                                        ? _purpose
                                        : 'その他',
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
                                    TransportationTextField(
                                      answerStatus:
                                          _submissionStatus == 'submitted'
                                          ? 1
                                          : 0,
                                      controller: _customPurposeController,
                                      initialAnswer: _customPurpose,
                                      onChanged: (val) {
                                        setState(() {
                                          _customPurpose = val;
                                        });
                                      },
                                      hintText: '具体的な目的を入力してください。',
                                    ),
                                  ],
                                  const SizedBox(height: 22),

                                  ReceiptSection(
                                    elementId: widget.singleId,
                                    // null이면 신규, 값 있으면 수정 모드로 간주
                                    isDisabled: _submissionStatus == 'submitted',
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

                                  CommonSubmitButtons(
                                    // 보존
                                    onSavePressed: () async {
                                      print('🔁 onSavePressed triggered');
                                      FocusScope.of(context).unfocus();

                                      print('선택한 파일 경로: ${_imageFile?.path}');

                                      if (_imageFile != null) {
                                        final uploadedFileName =
                                            await fetchImageUpload(
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
                                        _imageName =
                                            uploadedFileName; // 서버에서 받은 이미지 파일명 저장
                                        print('_imageName: ${_imageName}');
                                      }

                                      final saveData =
                                          widget.singleId == null
                                          ? TransportationSave(
                                              date: _selectedDate,
                                              expenseType: 'single',
                                              fromStation: _departure,
                                              toStation: _arrival,
                                              twice: _roundTrip,
                                              railwayName: _transport == 'その他'
                                                  ? (_customTransport ?? '')
                                                  : _transport,
                                              goals: _purpose == 'その他'
                                                  ? (_customPurpose ?? '')
                                                  : _purpose,
                                              amount: int.tryParse(
                                                _costController.text.trim(),
                                              ),
                                              image: _imageName ?? '',
                                              durationStart: _selectedDate
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first,
                                              submissionStatus: 'draft',
                                              // ✅ 보존은 null
                                              reviewStatus: '',
                                              id: widget.singleId,
                                            )
                                          : TransportationUpdate(
                                              date: _selectedDate,
                                              id: widget.singleId!,
                                              employeeId: "admins",
                                              // 임시
                                              expenseType: "single",
                                              amount: int.tryParse(
                                                _costController.text.trim(),
                                              ),
                                              durationStart: _selectedDate
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first,
                                              fromStation:
                                                  _departureController.text,
                                              toStation:
                                                  _arrivalController.text,
                                              twice: _roundTrip,
                                              railwayName: _transport == 'その他'
                                                  ? (_customTransport ?? '')
                                                  : _transport,
                                              goals: _purpose == 'その他'
                                                  ? (_customPurpose ?? '')
                                                  : _purpose,
                                              image: _imageName ?? '',
                                              submissionStatus: 'draft',
                                              reviewStatus: '',
                                            );

                                      print(
                                        'input transportation detail _selectedDate : ${_selectedDate}',
                                      );

                                      if (widget.singleId == null) {
                                        final success =
                                            await fetchTransportationSaveUpload(
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
                                          // Navigator.pushAndRemoveUntil(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                          //   ),
                                          //   (route) => false,
                                          // );
                                          Navigator.pop(context, _selectedDate);
                                        } else {
                                          attentionDialog(
                                            context,
                                            '保存エラー',
                                            '交通費保存に失敗しました。',
                                          );
                                        }
                                      } else {
                                        final success =
                                            await fetchTransportationSaveUpload(
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
                                          print(
                                            'update transportation detail _selectedDate : ${_selectedDate}',
                                          );
                                          // Navigator.pushAndRemoveUntil(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                          //   ),
                                          //   (route) => false,
                                          // );
                                          // print('update transportation detail _selectedDate : ${_selectedDate}');
                                          Navigator.pop(context, _selectedDate);
                                        } else {
                                          warningDialog(
                                            context,
                                            'エラー',
                                            '交通費保存に失敗しました。',
                                          );
                                        }
                                      }
                                    },

                                    // 삭제
                                    onSubmitPressed:
                                        widget.singleId != null
                                        ? () async {
                                            final success =
                                                await fetchTransportationDelete(
                                                  transportationId!,
                                                );
                                            if (success) {
                                              await successDialog(
                                                context,
                                                '削除完了',
                                                '交通費削除が完了しました。',
                                              );
                                              // Navigator.pushAndRemoveUntil(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                              //   ),
                                              //   (route) => false,
                                              // );
                                              Navigator.pop(
                                                context,
                                                _selectedDate,
                                              );
                                            } else {
                                              warningDialog(
                                                context,
                                                'エラー',
                                                '送信に失敗しました。',
                                              );
                                            }
                                          }
                                        : () {},

                                    // 🧑‍🎨 옵션 설정 (텍스트/색상)
                                    submitText: '削　　除',
                                    saveConfirmMessage: '交通費を保存しますか？',
                                    submitConfirmMessage: '交通費を削除しますか？',
                                    showSubmitButton:
                                        widget.singleId != null &&
                                        _submissionStatus == 'draft',
                                    showSaveButton:
                                        widget.singleId == null ||
                                        _submissionStatus == 'draft',
                                    // ← 조건부로 삭제 버튼 숨김
                                    themeColor: const Color(0xFFf35a01),
                                    padding: 0.0, // 원하는 색상
                                  ),
                                ],
                              ),
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
