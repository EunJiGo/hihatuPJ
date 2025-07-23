import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_drop_down.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_duration.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_image_upload.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/widgets/commuter_text_field.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/form_label.dart';
import 'package:hihatu_project/apply/transportations/transportation_screen.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/confirmation_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../utils/widgets/common_submit_buttons.dart';
import '../../summary/widgets/calendar_screen.dart';
import '../../summary/widgets/date_picker_button.dart';
import '../../transportation/constants/transportation_transport_options.dart';
import '../../transportation/data/fetch_transportation_save.dart';
import '../../transportation/domian/transportation_save.dart';

class CommuterScreen extends StatefulWidget {
  const CommuterScreen({super.key});

  @override
  State<CommuterScreen> createState() => _CommuterScreenState();
}

class _CommuterScreenState extends State<CommuterScreen> {
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
  File? _imageFile;
  PassDuration _duration = PassDuration.m1;

  // bool _hasViaStation = false;
  // final _viaStationController = TextEditingController();
  // List<String> _viaStationList = [];
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

    final nextMonthSameDay = DateTime(start.year, start.month + monthCount, start.day);
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


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text(
                '定期券申請',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3d3d3d),
                ),
              ),
              backgroundColor: Color(0xFF81C784),
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            body: SingleChildScrollView(
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
                    child: DatePickerButton(
                      date: _selectedDate,
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

                        FocusManager.instance.primaryFocus?.unfocus();

                        final picked = await Navigator.push<DateTime>(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    CalendarScreen(selectedDay: _selectedDate),
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
                  ),
                  const SizedBox(height: 28),

                  FormLabel(
                    text: '出発駅',
                    icon: Icons.my_location,
                    iconColor: Color(0xFF81C784),
                  ),
                  CommuterTextField(
                    answerStatus: 0,
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
                          child: Icon(Icons.add_circle_outline, size: 22, color: Colors.teal.shade700,),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: _viaCtrls.isNotEmpty
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
                        answerStatus: 0,
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
                    answerStatus: 0,
                    controller: _arrivalController,
                    initialAnswer: _arrival,
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
                            _hasViaStation ? Colors.teal.shade700 : Colors.grey,
                      ),
                      SizedBox(width: 3),
                      Text(
                        _hasViaStation ? '経由あり' : '経由なし',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color:
                              _hasViaStation
                                  ? Colors.teal.shade700
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
                            value: _hasViaStation,
                            onChanged: (v) {
                              FocusScope.of(context).unfocus();
                              _toggleVia(v);
                            },
                            activeColor: Colors.teal.shade700,
                            inactiveThumbColor: Colors.grey,
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
                    answerStatus: 0, // 비활성화면 1 넣기
                    selectedValue: _transport,
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
                      answerStatus: 0,
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
                    answerStatus: 0,
                    controller: _costController,
                    initialAnswer: _cost,
                    onChanged: (val) {
                      setState(() {
                        _cost = int.tryParse(val);
                      });
                    },
                    hintText: '金額を入力してください',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 22),

                  FormLabel(
                    text: '領収書/チケット添付',
                    icon: Icons.receipt_long,
                    iconColor: Color(0xFF81C784),
                  ),

                  CommuterImageUpload(
                    focusNode: FocusNode(),
                    imagePath: _imageFile?.path,
                    onImageSelected: (path) {
                      setState(() {
                        _imageFile = File(path);
                      });
                    },
                  ),

                  const SizedBox(height: 36),

                  // ✅ 하단 버튼 영역
                  CommonSubmitButtons(
                    onSavePressed: () async {
                      FocusScope.of(context).unfocus();

                      final bool? confirm = await ConfirmationDialog.show(
                        context,
                        message: '交通費を保存しますか？',
                      );
                      if (confirm != true) return;

                      final String? base64Image = _imageFile != null
                          ? base64Encode(await _imageFile!.readAsBytes())
                          : null;

                      final durationEnd = _calculatePassEndDate(_selectedDate, _duration);
                      final commuteDurationStr = _mapDurationToString(_duration);

                      final saveData = TransportationSave(
                        date: _selectedDate,
                        expenseType: 'commute',
                        fromStation: _departure,
                        toStation: _arrival,
                        twice: false,
                        railwayName: _transport == 'その他' ? (_customTransport ?? '') : _transport,
                        amount: int.tryParse(_costController.text.trim()) ?? 0,
                        image: base64Image ?? '',
                        durationStart: _selectedDate.toIso8601String().split('T').first,
                        durationEnd: durationEnd.toIso8601String().split('T').first,
                        commuteDuration: commuteDurationStr,
                        submissionStatus: 'draft', // ✅ 보존은 null
                        reviewStatus: '',
                      );

                      final success = await fetchTransportationSave(saveData);

                      if (success) {
                        await successDialog(context, '保存完了', '交通費保存が完了しました。');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const TransportationScreen()),
                              (route) => false,
                        );
                      } else {
                        attentionDialog(context, '保存エラー', '交通費保存に失敗しました。');
                      }
                    },

                    onSubmitPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (_hasViaStation && _viaValues.any((v) => v.trim().isEmpty)) {
                        attentionDialog(
                          context,
                          '未入力の経由駅があります',
                          'すべての経由駅を入力してください。',
                        );
                        return;
                      }

                      if (_departure.isEmpty ||
                          _arrival.isEmpty ||
                          (_transport == 'その他' &&
                              (_customTransport == null || _customTransport!.trim().isEmpty)) ||
                          _costController.text.trim().isEmpty) {
                        attentionDialog(
                          context,
                          '未入力の項目がある',
                          '未入力の項目を入力してください。',
                        );
                        return;
                      }

                      final bool? confirm = await ConfirmationDialog.show(
                        context,
                        message: '交通費を申請しますか？',
                      );
                      if (confirm != true) return;

                      final String? base64Image = _imageFile != null
                          ? base64Encode(await _imageFile!.readAsBytes())
                          : null;

                      final durationEnd = _calculatePassEndDate(_selectedDate, _duration);
                      final commuteDurationStr = _mapDurationToString(_duration);

                      final saveData = TransportationSave(
                        date: _selectedDate,
                        expenseType: "commute",
                        fromStation: _departure,
                        toStation: _arrival,
                        twice: false,
                        railwayName: _transport == 'その他' ? (_customTransport ?? '') : _transport,
                        amount: int.tryParse(_costController.text.trim()) ?? 0,
                        image: base64Image ?? '',
                        durationStart: _selectedDate.toIso8601String().split('T').first,
                        durationEnd: durationEnd.toIso8601String().split('T').first,
                        commuteDuration: commuteDurationStr,
                        submissionStatus: 'submitted', // ✅ 등록은 submitted
                        reviewStatus: 'pending',
                      );

                      final success = await fetchTransportationSave(saveData);

                      if (success) {
                        await successDialog(context, '登録完了', '交通費申請が完了しました。');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const TransportationScreen()),
                              (route) => false,
                        );
                      } else {
                        attentionDialog(context, '登録エラー', '交通費申請が失敗しました。');
                      }
                    },

                    // 🧑‍🎨 옵션 설정 (텍스트/색상)
                    saveText: '保　　存',
                    submitText: '登　　録',
                    saveConfirmMessage: '交通費を保存しますか？',
                    submitConfirmMessage: '交通費を申請しますか？',
                    themeColor: Colors.teal.shade700,
                    padding: 0.0, // 원하는 색상
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
