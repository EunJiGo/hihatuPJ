import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_drop_down.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_duration.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_image_upload.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_text_field.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/form_label.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_update.dart';
import 'package:hihatu_project/apply/transportations/transportation_screen.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../../../../utils/widgets/common_submit_buttons.dart';
import '../../summary/widgets/calendar_screen.dart';
import '../../summary/widgets/date_picker_button.dart';
import '../../transportation/constants/transportation_transport_options.dart';
import '../../transportation/data/fetch_image_upload.dart';
import '../../transportation/data/fetch_transportation_delete.dart';
import '../../transportation/data/fetch_transportation_save.dart';
import '../../transportation/domain/transportation_save.dart';
import '../../transportation/presentation/detail/widgets/transportation_image_upload.dart';
import '../../transportation/state/transportation_provider.dart';

class CommuterScreen extends ConsumerStatefulWidget {
  final int? commuteId;

  const CommuterScreen({this.commuteId, super.key});

  @override
  ConsumerState<CommuterScreen> createState() => _CommuterScreenState();
}

class _CommuterScreenState extends ConsumerState<CommuterScreen> {
  final TextEditingController _departureController = TextEditingController();

  final TextEditingController _arrivalController = TextEditingController();

  //_customTransport
  final TextEditingController _customTransportController =
      TextEditingController();

  // _purpose

  DateTime _selectedDate = DateTime.now();

  String _departure = '';
  String _arrival = '';
  String _transport = '電車';
  String? _customTransport;
  final _costController = TextEditingController();
  int? _cost;
  String? _imageName;
  File? _imageFile;
  PassDuration _duration = PassDuration.m1;
  String? _submissionStatus;

  bool _hasViaStation = false;
  final List<TextEditingController> _viaCtrls = [];
  final List<String> _viaValues = []; // 서버 전송/검증용

  void _toggleVia(bool v) {
    setState(() {
      _hasViaStation = v;
      if (v) {
        if (_viaCtrls.isEmpty) _addVia(); // 0개였다가 켜지면 1개 추가 (#4)
      } else {
        // 전부 정리
        for (final c in _viaCtrls) {
          c.dispose();
        }
        _viaCtrls.clear();
        _viaValues.clear();
      }
    });
  }

  void _addVia() {
    setState(() {
      final c = TextEditingController();
      _viaCtrls.add(c);
      _viaValues.add('');
    });
  }

  void _removeLastVia() {
    setState(() {
      if (_viaCtrls.isEmpty) return;

      _viaCtrls.removeLast().dispose();
      _viaValues.removeLast();

      // #3: 1개 남은 상태에서 지우면 전체 비활성
      if (_viaCtrls.isEmpty) {
        _hasViaStation = false;
      }
    });
  }

  Widget _arrowDown() =>
      const Center(child: Icon(Icons.south, color: Colors.grey, size: 15));

  // 정기권 종료일 계산 함수
  DateTime _calculatePassEndDate(DateTime start, PassDuration duration) {
    final monthCount = switch (duration) {
      PassDuration.m1 => 1,
      PassDuration.m3 => 3,
      PassDuration.m6 => 6,
    };

    final nextMonthSameDay = DateTime(
      start.year,
      start.month + monthCount,
      start.day,
    );
    return nextMonthSameDay.subtract(const Duration(days: 1)); // 하루 전날까지
  }

  String _mapDurationToString(PassDuration d) {
    switch (d) {
      case PassDuration.m1:
        return '1m';
      case PassDuration.m3:
        return '3m';
      case PassDuration.m6:
        return '6m';
    }
  }

  PassDuration _mapStringToDuration(String d) {
    switch (d) {
      case '1m':
        return PassDuration.m1;
      case '3m':
        return PassDuration.m3;
      case '6m':
        return PassDuration.m6;
      default:
        return PassDuration.m1; // 기본값 설정 (에러 방지)
    }
  }

  @override
  void initState() {
    super.initState();

    final commuteIdInt = widget.commuteId;
    if (commuteIdInt != null) {
      ref.read(transportationDetailProvider(commuteIdInt).future).then((
        detail,
      ) {
        if (mounted) {
          setState(() {
            _departureController.text = detail.fromStation;
            _arrivalController.text = detail.toStation;
            _costController.text = detail.amount.toString();
            _selectedDate =
                DateTime.tryParse(detail.durationStart) ?? DateTime.now();
            _duration = _mapStringToDuration(detail.commuteDuration);
            final isPresetTransport = transportationTransportOptions.contains(detail.railwayName);

            if (isPresetTransport) {
              _transport = detail.railwayName;
              _customTransport = null;
            } else {
              _transport = 'その他'; // 드롭다운에 표시
              _customTransport = detail.railwayName; // 입력 필드에 표시할 사용자 정의 값
              _customTransportController.text = detail.railwayName;
            }
            _imageName = detail.image;
            _submissionStatus = detail.submissionStatus;

            final viaString = detail.via;
            if (viaString.isNotEmpty) {
              final splitVia = viaString.split('、');
              for (final via in splitVia) {
                final controller = TextEditingController(text: via);
                _viaCtrls.add(controller);
                _viaValues.add(via);
              }
              _hasViaStation = _viaValues.isNotEmpty;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // commuteId가 있을 때만 provider 호출
    final commuteIdInt = widget.commuteId;
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context, _selectedDate);
                },
              ),
              title: const Text(
                '定期券申請',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3d3d3d),
                  // color: Colors.teal,
                ),
              ),
              backgroundColor: Color(0xFF81C784),
              // backgroundColor: Color(0xFF81C784),
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
                        text: '開始日',
                        icon: Icons.calendar_today,
                        iconColor: Color(0xFF81C784),
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
                                      titleColor: Color(0xFF81C784),
                                      contentColor: Color(0xFFFFF8F0),
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
                        text: '定期券期間',
                        icon: Icons.event_repeat,
                        iconColor: Color(0xFF81C784),
                      ),
                      PassDurationRadioRow(
                        value: _duration,
                        onChanged: (newDuration) {
                          setState(() {
                            _duration = newDuration;
                            // 필요 시 종료일 자동 계산
                            // _endDate = _calcEndDate(_selectedDate, newDuration);
                          });
                        },
                        isDisabled: _submissionStatus == 'submitted' ? true : false,
                      ),
                      const SizedBox(height: 28),

                      FormLabel(
                        text: '出発駅',
                        icon: Icons.my_location,
                        iconColor: Color(0xFF81C784),
                      ),
                      CommuterTextField(
                        answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                        controller: _departureController,
                        // initialAnswer: _departureController.text,
                        onChanged: (val) {
                          setState(() {
                            _departure = val;
                          });
                        },
                        hintText: "例）荻窪",
                      ),

                      const SizedBox(height: 10),

                      if (_hasViaStation) ...[
                        const SizedBox(height: 3),
                        _arrowDown(),

                        Row(
                          children: [
                            Expanded(
                              child: FormLabel(
                                text:
                                    '経由駅${_viaCtrls.isNotEmpty ? '（${_viaCtrls.length}個）' : ''}',
                                icon: Icons.transfer_within_a_station,
                                iconColor: const Color(0xFF81C784),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _addVia();
                              },
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 22,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap:
                                  _viaCtrls.isNotEmpty
                                      ? () {
                                        FocusScope.of(context).unfocus();
                                        _removeLastVia();
                                      }
                                      : null,
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 22,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ],
                        ),

                        // 필드들
                        for (int i = 0; i < _viaCtrls.length; i++) ...[
                          if (i != 0) ...[const SizedBox(height: 15)],
                          CommuterTextField(
                            answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                            controller: _viaCtrls[i],
                            initialAnswer: _viaValues[i],
                            onChanged: (val) {
                              setState(() {
                                _viaValues[i] = val;
                              });
                            },
                            hintText: '例）新宿',
                          ),
                          const SizedBox(height: 15),
                          _arrowDown(), // #1, #5: 각 필드 뒤에 아래 화살표 넣는다면
                        ],
                      ],

                      // const SizedBox(height: 12),
                      FormLabel(
                        text: '到着駅',
                        icon: Icons.location_on,
                        iconColor: Color(0xFF81C784),
                      ),
                      CommuterTextField(
                        answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
                        controller: _arrivalController,
                        // initialAnswer: _arrivalController.text,
                        onChanged: (val) {
                          setState(() {
                            _arrival = val;
                          });
                        },
                        hintText: "例）品川",
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center, // 변경
                        children: [
                          Icon(
                            Icons.transfer_within_a_station,
                            size: 16,
                            color:
                                _submissionStatus == 'submitted' ?
                                    Colors.black26
                                    :
                                _hasViaStation
                                    ? Colors.teal.shade700
                                    : Colors.grey,
                          ),
                          SizedBox(width: 3),
                          Text(
                            _hasViaStation ? '経由あり' : '経由なし',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color:
                              _submissionStatus == 'submitted' ?
                              Colors.black26
                              :
                                  _hasViaStation
                                      ? Colors.teal.shade700
                                      : Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Transform.translate(
                            offset: const Offset(0, -2), // 위로 약간 이동시킴
                            child: Transform.scale(
                              // 스위치 크기 조절 위함
                              scale: 0.8, // 크기를 80%로 줄임 (1.0이 기본)
                              child: Switch.adaptive(
                                value: _hasViaStation,
                                onChanged:  _submissionStatus == 'submitted' ? null : (v) {
                                  FocusScope.of(context).unfocus();
                                  _toggleVia(v);
                                },
                                activeColor: _submissionStatus == 'submitted' ? Colors.black45 : Colors.teal.shade700,
                                inactiveThumbColor: _submissionStatus == 'submitted' ?
                                Colors.black26
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      FormLabel(
                        text: '交通手段',
                        icon: Icons.directions_transit,
                        iconColor: Color(0xFF81C784),
                      ),
                      CommuterDropDown(
                        options: transportationTransportOptions,
                        answerStatus: _submissionStatus == 'submitted' ? 1 : 0, // 비활성화면 1 넣기
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
                        CommuterTextField(
                          answerStatus: _submissionStatus == 'submitted' ? 1 : 0,
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
                        text: '金額 (\u5186)',
                        icon: Icons.attach_money,
                        iconColor: Color(0xFF81C784),
                      ),
                      CommuterTextField(
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
                        iconColor: Color(0xFF81C784),
                      ),

                      // 이미 저장된 걸 가지고 옴
                      if (commuteIdInt != null) ...[
                        CommuterImageUpload(
                          focusNode: FocusNode(),
                          imagePath: _imageName,
                          themeColor: const Color(0xFF81C784),
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
                          themeColor: const Color(0xFF81C784),
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

                          final durationEnd = _calculatePassEndDate(
                            _selectedDate,
                            _duration,
                          );
                          final commuteDurationStr = _mapDurationToString(
                            _duration,
                          );

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
                              widget.commuteId == null
                                  ? TransportationSave(
                                    date: _selectedDate,
                                    expenseType: 'commute',
                                    fromStation: _departure,
                                    toStation: _arrival,
                                    via:
                                        _hasViaStation
                                            ? _viaValues
                                                .where(
                                                  (v) => v.trim().isNotEmpty,
                                                )
                                                .join('、')
                                            : '',
                                    twice: false,
                                    railwayName:
                                        _transport == 'その他'
                                            ? (_customTransport ?? '')
                                            : _transport,
                                    amount: int.tryParse(
                                      _costController.text.trim(),
                                    ),
                                    image: _imageName ?? '',
                                    durationStart:
                                        _selectedDate
                                            .toIso8601String()
                                            .split('T')
                                            .first,
                                    durationEnd:
                                        durationEnd
                                            .toIso8601String()
                                            .split('T')
                                            .first,
                                    commuteDuration: commuteDurationStr,
                                    submissionStatus: 'draft',
                                    // ✅ 보존은 null
                                    reviewStatus: '',
                                    id: widget.commuteId,
                                  )
                                  : TransportationUpdate(
                                    date: _selectedDate,
                                    id: widget.commuteId!,
                                    employeeId: "admins",
                                    // 임시
                                    expenseType: "commute",
                                    amount: int.tryParse(
                                      _costController.text.trim(),
                                    ),
                                    commuteDuration: commuteDurationStr,
                                    durationStart:
                                        _selectedDate
                                            .toIso8601String()
                                            .split('T')
                                            .first,
                                    durationEnd:
                                        durationEnd
                                            .toIso8601String()
                                            .split('T')
                                            .first,
                                    fromStation: _departureController.text,
                                    toStation: _arrivalController.text,
                                    twice: false,
                                    via:
                                        _hasViaStation
                                            ? _viaValues
                                                .where(
                                                  (v) => v.trim().isNotEmpty,
                                                )
                                                .join('、')
                                            : '',
                                    railwayName:
                                        _transport == 'その他'
                                            ? (_customTransport ?? '')
                                            : _transport,
                                    image: _imageName ?? '',
                                    submissionStatus: 'draft',
                                    reviewStatus: '',
                                  );

                          if (widget.commuteId == null) {
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
                              // Navigator.pushAndRemoveUntil(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                              //   ),
                              //   (route) => false,
                              // );
                              Navigator.pop(context, _selectedDate);
                            } else {
                              warningDialog(context, 'エラー', '交通費保存に失敗しました。');
                            }
                          }
                        },

                        // 삭제
                        onSubmitPressed:
                            widget.commuteId != null
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
                                    // Navigator.pushAndRemoveUntil(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (_) => TransportationScreen(initialDate: _selectedDate,),
                                    //
                                    //   ),
                                    //   (route) => false,
                                    // );
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
                        showSubmitButton: widget.commuteId != null && _submissionStatus == 'draft',
                        showSaveButton: widget.commuteId == null || _submissionStatus == 'draft' ,
                        // ← 조건부로 삭제 버튼 숨김
                        themeColor: Colors.teal.shade700,
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
