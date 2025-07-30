import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/form_label.dart';
import 'package:hihatu_project/apply/transportations/transportation/presentation/detail/widgets/transportation_image_upload.dart';
import 'package:hihatu_project/apply/transportations/transportation_screen.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/confirmation_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../summary/widgets/date_picker_button.dart';
import 'widgets/transportation_drop_down.dart';
import 'widgets/transportation_text_field.dart';
import '../../constants/transportation_purpose_options.dart';
import '../../constants/transportation_transport_options.dart';
import '../../data/fetch_transportation_save.dart';
import '../../domian/transportation_save.dart';
import '../../../summary/widgets/calendar_screen.dart';

class TransportationInputScreen extends StatefulWidget {
  const TransportationInputScreen({super.key});

  @override
  State<TransportationInputScreen> createState() =>
      _TransportationInputScreenState();
}

class _TransportationInputScreenState extends State<TransportationInputScreen> {
  final TextEditingController _departureController = TextEditingController();
  final FocusNode _departureFocusNode = FocusNode();

  final TextEditingController _arrivalController = TextEditingController();
  final FocusNode _arrivalFocusNode = FocusNode();

  //_customTransport
  final TextEditingController _customTransportController = TextEditingController();
  // _purpose
  final TextEditingController _customPurposeController = TextEditingController();

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
  File? _imageFile;


  @override
  void initState() {
    super.initState();
    _departureFocusNode.addListener(() {
      setState(() {}); // 포커스 상태가 바뀌면 UI 재렌더
    });
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = Color(0xFF303030);

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
                '交通費申請',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3d3d3d),
                ),
              ),
              backgroundColor: Color(0xFF81C784),
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20)),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(text: '日付',
                      icon: Icons.calendar_today,
                      iconColor: Color(0xFF81C784)),
                  Center(
                    child: DatePickerButton(
                      date: _selectedDate,
                      backgroundColor: Colors.white,
                      borderRadius: 20,
                      shadowColor: const Color(0xFF8e8e8e),
                      onPick: () async {
                        print('scope(hasFocus): ${FocusScope.of(context).hasFocus}');
                        print('primaryFocus: ${FocusManager.instance.primaryFocus}');

                        FocusManager.instance.primaryFocus?.unfocus();

                        final picked = await Navigator.push<DateTime>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CalendarScreen(selectedDay: _selectedDate),
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

                  FormLabel(text: '出発駅',
                      icon: Icons.my_location,
                      iconColor: Color(0xFF81C784)),
                  TransportationTextField(
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

                  FormLabel(text: '到着駅',
                      icon: Icons.location_on,
                      iconColor: Color(0xFF81C784)),
                  TransportationTextField(
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

                  // const SizedBox(height: 18),

                  // 왕복
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center, // 변경
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: _roundTrip ? Colors.teal.shade700 : Colors.grey,
                      ),
                      SizedBox(width: 3),
                      Text(
                        _roundTrip ? '往復あり' : '往復なし',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _roundTrip ? Colors.teal.shade700 : Colors
                              .grey,
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
                            onChanged: (val) =>
                                setState(() => _roundTrip = val),
                            activeColor: labelColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  FormLabel(text: '交通手段',
                      icon: Icons.directions_transit,
                      iconColor: Color(0xFF81C784)),
                  TransportationDropDown(
                    options: transportationTransportOptions,
                    answerStatus: 0,                // 비활성화면 1 넣기
                    selectedValue: _transport,
                    onChanged: (val) {
                      setState(() {
                        _transport = val ?? '';
                        _customTransport = null;

                        if(_transport != 'その他') {
                          _customTransportController.clear();
                        }
                      });
                    },
                  ),

                  if (_transport == 'その他') ...[
                    const SizedBox(height: 12),
                    TransportationTextField(
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

                  FormLabel(text: '費用 (\u5186)',
                      icon: Icons.attach_money,
                      iconColor: Color(0xFF81C784)),
                  TransportationTextField(
                    answerStatus: 0,
                    controller: _costController,
                    initialAnswer: _cost,
                    onChanged: (val) {
                      setState(() {
                        _cost = int.tryParse(val);
                      });
                    },
                    hintText: _roundTrip
                        ? '往復の交通費を入力してください'
                        : '片道の交通費を入力してください',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 22),

                  FormLabel(text: '目的',
                      icon: Icons.flag,
                      iconColor: Color(0xFF81C784)),
                  TransportationDropDown(
                    options: transportationPurposeOptions,
                    answerStatus: 0,                // 비활성화면 1 넣기
                    selectedValue: _purpose,
                    onChanged: (val) {
                      setState(() {
                        _purpose = val ?? '';
                        _customPurpose = null;

                        if(_purpose != 'その他') {
                          _customPurposeController.clear();
                        }
                      });
                    },
                  ),
                  if (_purpose == 'その他') ...[
                    const SizedBox(height: 12),
                    TransportationTextField(
                      answerStatus: 0,
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

                  FormLabel(text: '領収書/チケットア添付',
                      icon: Icons.receipt_long,
                      iconColor: Color(0xFF81C784)),

                  TransportationImageUpload(
                    focusNode: FocusNode(),
                    imagePath: _imageFile?.path,
                    onImageSelected: (path) {
                      setState(() {
                        _imageFile = File(path);
                      });
                    },
                  ),

                  const SizedBox(height: 36),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        // 필수 항목이 하나라도 비어 있으면 경고 다이얼로그 표시
                        if (_departure.isEmpty ||
                            _arrival.isEmpty ||
                            (_transport == 'その他' &&
                                (_customTransport == null ||
                                    _customTransport!.trim().isEmpty)) ||
                            _costController.text
                                .trim()
                                .isEmpty ||
                            (_purpose == 'その他' &&
                                (_customPurpose == null ||
                                    _customPurpose!.trim().isEmpty))) {
                          attentionDialog(
                            context,
                            '未入力の項目がある',
                            '未入力の項目を入力してください。',
                          );
                          return;
                        }

                        // 제출 처리 로직 작성
                        // 확인 다이얼로그 띄우기
                        final bool? confirm = await ConfirmationDialog.show(
                          context,
                          message: '交通費を申請しますか？',
                        );

                        if (confirm == true) {
                          // 이미지 base64 인코딩
                          String? base64Image;
                          if (_imageFile != null) {
                            final bytes = await _imageFile!.readAsBytes();
                            base64Image = base64Encode(bytes);
                          }

                          // 서버 전송용 객체 생성
                          final saveData = TransportationSave(
                            date: _selectedDate,
                            expenseType: "single",
                            fromStation: _departure,
                            toStation: _arrival,
                            twice: _roundTrip,
                            railwayName:
                            _transport == 'その他'
                                ? (_customTransport ?? '')
                                : _transport,
                            amount:
                            int.tryParse(_costController.text.trim()) ?? 0,
                            goals:
                            _purpose == 'その他'
                                ? (_customPurpose ?? '')
                                : _purpose,
                            image: base64Image ?? '',
                            submissionStatus: 'draft',
                            reviewStatus: 'pending',
                          );

                          // 서버에 전송
                          // bool success = await fetchTransportationSave(
                          //     saveData);

                          if (true) {
                            await successDialog(
                              context,
                              '登録完了',
                              '交通費申請が完了しました。',
                            );
                            // 화면 닫기
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const TransportationScreen(),
                              ),
                                  (Route<dynamic> route) => false,
                            );
                          } else {
                            attentionDialog(
                              context,
                              '登録エラー',
                              '交通費申請が失敗しました。',
                            );
                          }
                        } else {
                          // 취소한 경우 아무 동작 없음
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF81C784),
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 56, // ➜ 가로(좌우) 여백
                          vertical: 8, // ➜ 세로(상하) 여백
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 6,
                        shadowColor: Colors.teal.shade300.withOpacity(0.5),
                      ),
                      child: const Text(
                        '登　　録',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004D40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
