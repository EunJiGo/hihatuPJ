import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hihatu_project/apply/features/transportation/presentation/transportation_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../../../tabbar/htt_tabbar.dart';
import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/confirmation_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../data/fetch_transportation.dart';
import '../../../data/fetch_transportation_save.dart';
import '../../../domian/transportation_item.dart';
import '../../../domian/transportation_save.dart';
import '../calendar_screem.dart';

class TransportationInputScreen extends StatefulWidget {
  const TransportationInputScreen({super.key});

  @override
  State<TransportationInputScreen> createState() =>
      _TransportationInputScreenState();
}

class _TransportationInputScreenState extends State<TransportationInputScreen> {
  DateTime _selectedDate = DateTime.now();

  String _departure = '';
  List<String> _transferStations = []; // 환승역 리스트

  String _arrival = '';

  String _transport = '電車';
  String? _customTransport;
  bool _roundTrip = false;
  String _purpose = '出勤';
  String? _customPurpose;
  final _costController = TextEditingController();
  File? _imageFile;

  final List<String> _transportOptions = [
    '電車',
    'バス',
    'タクシー',
    '飛行機',
    '自家用車',
    'その他',
  ];
  final List<String> _purposeOptions = [
    '出勤',
    '打ち合わせ',
    '安全確認',
    '作業',
    'イベント',
    '研修',
    '営業',
    'その他',
  ];

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('カメラで撮影'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('ギャラリーから選択'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.redAccent),
                title: const Text('キャンセル'),
                onTap: () {
                  Navigator.pop(context);
                  // 취소 시 특별 처리 없으면 그냥 모달 닫힘
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _addTransferStation() {
    setState(() {
      _transferStations.add('');
    });
  }

  void _removeTransferStation() {
    if (_transferStations.isNotEmpty) {
      setState(() {
        _transferStations.removeLast();
      });
    }
  }

  Widget _buildLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Color(0xFF81C784)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    void Function(String)? onChanged,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required Color borderColor,
    required Color boxBackgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: Colors.blueGrey.shade800,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.blueGrey.shade300),
          filled: true,
          fillColor: boxBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          // focusColor:
        ),
      ),
    );
  }

  // Widget _buildDropdown(
  //   String value,
  //   List<String> options,
  //   void Function(String) onChanged, {
  //   required Color borderColor,
  //   required Color boxBackgroundColor,
  // }) {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 46,
  //     child: DropdownButtonFormField<String>(
  //       value: value,
  //       items:
  //           options
  //               .map(
  //                 (item) => DropdownMenuItem(
  //                   value: item,
  //                   child: Text(
  //                     item,
  //                     style: TextStyle(
  //                       color: Colors.teal.shade900,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               )
  //               .toList(),
  //       onChanged: (val) => onChanged(val!),
  //       decoration: InputDecoration(
  //         filled: true,
  //         fillColor: boxBackgroundColor,
  //         contentPadding: const EdgeInsets.symmetric(
  //           horizontal: 18,
  //           vertical: 12,
  //         ),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(20),
  //           borderSide: BorderSide(color: borderColor),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(20),
  //           borderSide: BorderSide(color: borderColor, width: 2),
  //         ),
  //       ),
  //       dropdownColor: Colors.white,
  //     ),
  //   );
  // }

  Widget _buildDropdown(
    String value,
    List<String> options,
    void Function(String) onChanged, {
    required Color borderColor,
    required Color boxBackgroundColor,
  }) {
    return GestureDetector(
      onTap: () {
        // 모달 방식으로 선택창 표시
        showModalBottomSheet(
          context: context,
          // context는 외부에서 받아야 합니다.
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final bool isSelected = opt == value;

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              onChanged(opt);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFFE3F2FD)
                                        : const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? const Color(0xFF64B5F6)
                                          : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: Colors.blue.shade100
                                                .withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color:
                                        isSelected
                                            ? Colors.blueAccent
                                            : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? const Color(0xFF1565C0)
                                                : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33FF5252),
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Text(
                          'キャンセル',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: AbsorbPointer(
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(text: value),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              // labelText: '選択してください',
              labelStyle: const TextStyle(color: Color(0xFF1565C0)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: boxBackgroundColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferStationInput(
    int index,
    Color borderColor,
    Color boxBackgroundColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('乗り換え駅 ${index + 1}'),
        _buildTextField(
          '例: 新宿',
          onChanged: (val) {
            _transferStations[index] = val;
          },
          borderColor: borderColor,
          boxBackgroundColor: boxBackgroundColor,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF8e8e8e);
    const boxBackgroundColor = Colors.white;
    final labelColor = Color(0xFF303030);

    return Container(
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('日付', icon: Icons.calendar_today),
                Center(
                  child: _buildDatePicker(borderColor, boxBackgroundColor),
                ),
                const SizedBox(height: 22),

                _buildLabel('出発駅', icon: Icons.train),
                _buildTextField(
                  '例: 新宿',
                  onChanged: (val) => _departure = val,
                  borderColor: borderColor,
                  boxBackgroundColor: boxBackgroundColor,
                ),

                const SizedBox(height: 10),

                // // 플러스/마이너스 버튼
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     IconButton(
                //       icon: Icon(
                //         Icons.remove_circle_outline,
                //         color:
                //             _transferStations.isNotEmpty
                //                 ? Colors.teal
                //                 : Colors.grey,
                //       ),
                //       onPressed:
                //           _transferStations.isNotEmpty
                //               ? _removeTransferStation
                //               : null,
                //       tooltip: '乗り換え駅を削除',
                //     ),
                //     const SizedBox(width: 12),
                //     IconButton(
                //       icon: Icon(Icons.add_circle_outline, color: Colors.teal),
                //       onPressed: _addTransferStation,
                //       tooltip: '乗り換え駅を追加',
                //     ),
                //   ],
                // ),
                //
                // const SizedBox(height: 18),

                // // 환승역 입력창 + 화살표
                // ...List.generate(_transferStations.length, (index) {
                //   return Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       _buildTransferStationInput(
                //         index,
                //         borderColor,
                //         boxBackgroundColor,
                //       ),
                //       if (index < _transferStations.length - 1)
                //         Center(
                //           child: Icon(
                //             Icons.keyboard_arrow_down,
                //             color: Colors.teal.shade300,
                //             size: 30,
                //           ),
                //         ),
                //     ],
                //   );
                // }),

                // const SizedBox(height: 18),

                // // 환승역 입력란들
                // ...List.generate(_transferStations.length, (index) {
                //   return _buildTransferStationInput(
                //     index,
                //     borderColor,
                //     boxBackgroundColor,
                //   );
                // }),
                _buildLabel('到着駅', icon: Icons.location_on),
                _buildTextField(
                  '例: 品川',
                  onChanged: (val) => _arrival = val,
                  borderColor: borderColor,
                  boxBackgroundColor: boxBackgroundColor,
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
                        color: _roundTrip ? Colors.teal.shade700 : Colors.grey,
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
                          onChanged: (val) => setState(() => _roundTrip = val),
                          activeColor: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildLabel('交通手段', icon: Icons.directions_transit),
                _buildDropdown(
                  _transport,
                  _transportOptions,
                  (val) {
                    setState(() {
                      _transport = val;
                      _customTransport = null;
                    });
                  },
                  borderColor: borderColor,
                  boxBackgroundColor: boxBackgroundColor,
                ),
                if (_transport == 'その他') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    '交通手段を入力',
                    onChanged: (val) => _customTransport = val,
                    borderColor: borderColor,
                    boxBackgroundColor: boxBackgroundColor,
                  ),
                ],
                const SizedBox(height: 22),

                _buildLabel('費用 (\u5186)', icon: Icons.attach_money),
                _buildTextField(
                  _roundTrip ? '往復の交通費を入力してください': '片道の交通費を入力してください',
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  borderColor: borderColor,
                  boxBackgroundColor: boxBackgroundColor,
                ),
                const SizedBox(height: 22),

                _buildLabel('目的', icon: Icons.flag),
                _buildDropdown(
                  _purpose,
                  _purposeOptions,
                  (val) {
                    setState(() {
                      _purpose = val;
                      _customPurpose = null;
                    });
                  },
                  borderColor: borderColor,
                  boxBackgroundColor: boxBackgroundColor,
                ),
                if (_purpose == 'その他') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    '具体的な目的を入力',
                    onChanged: (val) => _customPurpose = val,
                    borderColor: borderColor,
                    boxBackgroundColor: boxBackgroundColor,
                  ),
                ],
                const SizedBox(height: 22),

                _buildLabel('領収書/チケットア添付', icon: Icons.receipt_long),
                GestureDetector(
                  onTap: _showImageSourceSelector,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: boxBackgroundColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade100.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child:
                        _imageFile == null
                            ? Center(
                              child: Icon(
                                Icons.cloud_upload,
                                size: 44,
                                color: Color(0xFF81C784),
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            ),
                  ),
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
                          _costController.text.trim().isEmpty ||
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
                          submissionStatus: 'submitted',
                          reviewStatus: 'pending',
                        );

                        // 서버에 전송
                        bool success = await fetchTransportationSave(saveData);

                        if (success) {
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
    );
  }

  Widget _buildDatePicker(Color borderColor, Color boxBackgroundColor) {
    return GestureDetector(
      onTap: () async {
        final picked = await Navigator.push<DateTime>(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarScreen(selectedDay: _selectedDate),
          ),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: boxBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8e8e8e),
              // color: Colors.teal.shade100.withOpacity(0.7),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.calendar_today, color: Colors.teal.shade400),
            const SizedBox(width: 10),
            Text(
              '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF263238),
                // color: Colors.teal.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
