import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/form_label.dart';
import 'package:hihatu_project/apply/transportations/transportation/presentation/detail/widgets/transportation_image_upload.dart';
import 'package:hihatu_project/apply/transportations/transportation_screen.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../../utils/dialog/warning_dialog.dart';
import '../../../../../utils/widgets/common_submit_buttons.dart';
import '../../../commuter/presentation/widgets/commuter_image_upload.dart';
import '../../../summary/widgets/date_picker_button.dart';
import '../../data/fetch_image_upload.dart';
import '../../data/fetch_transportation_delete.dart';
import '../../data/fetch_transportation_save.dart';
import '../../domain/transportation_update.dart';
import '../../state/transportation_provider.dart';
import 'widgets/transportation_drop_down.dart';
import 'widgets/transportation_text_field.dart';
import '../../constants/transportation_purpose_options.dart';
import '../../constants/transportation_transport_options.dart';
import '../../domain/transportation_save.dart';
import '../../../summary/widgets/calendar_screen.dart';

class TransportationInputScreen extends ConsumerStatefulWidget {
  final int? transportationId;

  const TransportationInputScreen({this.transportationId, super.key});

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
  String _purpose = '出勤';
  String? _customPurpose;
  final _costController = TextEditingController();
  int? _cost;
  String? _imageName;
  File? _imageFile;
  String? _submissionStatus;

  @override
  void initState() {
    super.initState();
    final transportationId = widget.transportationId;
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
                DateTime.tryParse(detail.durationStart) ?? DateTime.now();

            final isPresetTransport = transportationTransportOptions.contains(detail.railwayName);
            if (isPresetTransport) {
              _transport = detail.railwayName;
              _customTransport = null;
            } else {
              _transport = 'その他'; // 드롭다운에 표시
              _customTransport = detail.railwayName; // 입력 필드에 표시할 사용자 정의 값
              _customTransportController.text = detail.railwayName;
            }

            final isPresetPurpose = transportationTransportOptions.contains(detail.goals);
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
    final transportationId = widget.transportationId;
    final detailAsync =
        transportationId != null
            ? ref.watch(transportationDetailProvider(transportationId))
            : null;

    print('transportationId ${transportationId}');
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                '交通費申請',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3d3d3d),
                ),
              ),
              backgroundColor: Color(0xFFFFB74D),
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
                return Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel(
                          text: '日付',
                          icon: Icons.calendar_today,
                          iconColor: Color(0xFFFFB74D),
                        ),
                        Center(
                          child:
                              _submissionStatus == "submitted"
                                  ? DatePickerButton(
                                    date: _selectedDate,
                                isFullDate: true,
                                    backgroundColor: Colors.grey.shade200,
                                    // 비활성화 스타일
                                    borderRadius: 20,
                                    shadowColor: const Color(0xFF8e8e8e),
                                    onPick: () async {
                                      return _selectedDate; // 그냥 현재 날짜 리턴, 아무것도 안 바꿈
                                    },
                                  )
                                  : DatePickerButton(
                                    date: _selectedDate,
                                isFullDate: true,
                                    backgroundColor: Colors.white,
                                    borderRadius: 20,
                                    shadowColor: const Color(0xFF8e8e8e),
                                    onPick: () async {
                                      print(
                                        'scope(hasFocus): ${FocusScope.of(context).hasFocus}',
                                      );
                                      print(
                                        'primaryFocus: ${FocusManager.instance.primaryFocus}',
                                      );

                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      final picked =
                                          await Navigator.push<DateTime>(
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
                        const SizedBox(height: 22),

                        FormLabel(
                          text: '出発駅',
                          icon: Icons.my_location,
                          iconColor: Color(0xFFFFB74D),
                        ),
                        TransportationTextField(
                          answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                          controller: _departureController,
                          initialAnswer: _departure,
                          onChanged: (val) {
                            setState(() {
                              _departure = val;
                            });
                          },
                          hintText: "例）荻窪",
                        ),

                        const SizedBox(height: 10),

                        FormLabel(
                          text: '到着駅',
                          icon: Icons.location_on,
                          iconColor: Color(0xFFFFB74D),
                        ),
                        TransportationTextField(
                          answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                          controller: _arrivalController,
                          initialAnswer: _arrival,
                          onChanged: (val) {
                            setState(() {
                              _arrival = val;
                            });
                          },
                          hintText: "例）品川",
                        ),

                        // const SizedBox(height: 18),

                        // 왕복
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center, // 변경
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 16,
                              color:
                                  _submissionStatus == 'submitted'
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
                              offset: const Offset(0, -2), // 위로 약간 이동시킴
                              child: Transform.scale(
                                // 스위치 크기 조절 위함
                                scale: 0.8, // 크기를 80%로 줄임 (1.0이 기본)
                                child: Switch.adaptive(
                                  value: _roundTrip,
                                  onChanged:
                                      _submissionStatus == 'submitted'
                                          ? null
                                          : (val) {
                                            setState(() => _roundTrip = val);
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

                        FormLabel(
                          text: '交通手段',
                          icon: Icons.directions_transit,
                          iconColor: Color(0xFFFFB74D),
                        ),
                        TransportationDropDown(
                          options: transportationTransportOptions,
                          answerStatus:
                              _submissionStatus == 'submitted'
                                  ? 1
                                  : 0, // 비활성화면 1 넣기
                          selectedValue: transportationTransportOptions.contains(_transport) ? _transport : 'その他',
                          onChanged: (val) {
                            setState(() {
                              _transport = val ?? '';
                              _customTransport = null;

                              if (_transport != 'その他') {
                                _customTransportController.clear();
                              }
                            });
                          },
                        ),

                        if (_transport == 'その他') ...[
                          const SizedBox(height: 12),
                          TransportationTextField(
                            answerStatus:
                                _submissionStatus == 'submitted' ? 1 : 0,
                            controller: _customTransportController,
                            initialAnswer: _customTransport,
                            onChanged: (val) {
                              setState(() {
                                _customTransport = val;
                              });
                            },
                            hintText: '交通手段を入力してください。',
                          ),
                        ],
                        const SizedBox(height: 22),

                        FormLabel(
                          text: '費用 (\u5186)',
                          icon: Icons.attach_money,
                          iconColor: Color(0xFFFFB74D),
                        ),
                        TransportationTextField(
                          answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                          controller: _costController,
                          initialAnswer: _cost,
                          onChanged: (val) {
                            setState(() {
                              _cost = int.tryParse(val);
                            });
                          },
                          hintText:
                              _roundTrip ? '往復の交通費を入力してください' : '片道の交通費を入力してください',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
                          selectedValue: transportationPurposeOptions.contains(_purpose) ? _purpose : 'その他',
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
                                _submissionStatus == 'submitted' ? 1 : 0,
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

                        FormLabel(
                          text: '領収書/チケットア添付',
                          icon: Icons.receipt_long,
                          iconColor: Color(0xFFFFB74D),
                        ),

                        // 이미 저장된 걸 가지고 옴
                        if (transportationId != null) ...[
                          CommuterImageUpload(
                            focusNode: FocusNode(),
                            imagePath: _imageName,
                            themeColor: const Color(0xFFfea643),
                            shadowColor: const Color(0xFFfea643),
                            isDisabled:
                                _submissionStatus == 'submitted'
                                    ? true
                                    : false, // 업로드 활성화 -- 이상
                            onImageSelected: (path) {
                              setState(() {
                                _imageFile = File(path);
                                _imageName = path.split('/').last;
                              });
                            },
                          ),
                        ],

                        if (transportationId == null) ...[
                          TransportationImageUpload(
                            focusNode: FocusNode(),
                            imagePath: _imageFile?.path,
                            themeColor: const Color(0xFFfea643),
                            onImageSelected: (path) {
                              setState(() {
                                _imageFile = File(path);
                              });
                            },
                          ),
                        ],

                        const SizedBox(height: 36),

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
                              print('_imageName: ${_imageName}');
                            }

                            final saveData =
                                widget.transportationId == null
                                    ? TransportationSave(
                                      date: _selectedDate,
                                      expenseType: 'single',
                                      fromStation: _departure,
                                      toStation: _arrival,
                                      twice: _roundTrip,
                                      railwayName:
                                          _transport == 'その他'
                                              ? (_customTransport ?? '')
                                              : _transport,
                                  goals:
                                  _purpose == 'その他'
                                      ? (_customPurpose ?? '')
                                      : _purpose,
                                      amount: int.tryParse(
                                        _costController.text.trim(),
                                      ),
                                      image: _imageName ?? '',
                                      durationStart:
                                          _selectedDate
                                              .toIso8601String()
                                              .split('T')
                                              .first,
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
                                      expenseType: "single",
                                      amount: int.tryParse(
                                        _costController.text.trim(),
                                      ),
                                      durationStart:
                                          _selectedDate
                                              .toIso8601String()
                                              .split('T')
                                              .first,
                                      fromStation: _departureController.text,
                                      toStation: _arrivalController.text,
                                      twice: _roundTrip,
                                      railwayName:
                                          _transport == 'その他'
                                              ? (_customTransport ?? '')
                                              : _transport,
                                  goals:
                                  _purpose == 'その他'
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
                                // Navigator.pushAndRemoveUntil(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                //   ),
                                //   (route) => false,
                                // );
                                Navigator.pop(context, true);
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
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                  ),
                                  (route) => false,
                                );
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
                                          transportationId!,
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
                                          builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                        ),
                                        (route) => false,
                                      );
                                    } else {
                                      warningDialog(context, 'エラー', '送信に失敗しました。');
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
        ),
      ),
    );
  }
}
