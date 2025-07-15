import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    '立ち会い',
    '安全確認',
    '作業',
    'イベント',
    '研修',
    '営業',
    'その他',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
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

  Widget _buildDropdown(
    String value,
    List<String> options,
    void Function(String) onChanged, {
    required Color borderColor,
    required Color boxBackgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            options
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: Colors.teal.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged: (val) => onChanged(val!),
        decoration: InputDecoration(
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
        ),
        dropdownColor: Colors.white,
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
    const borderColor = Color(0xFF81D4FA);
    const boxBackgroundColor = Colors.white;
    final labelColor = Colors.teal.shade700;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('交通費入力'),
        backgroundColor: Colors.teal.shade400,
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
            Center(child: _buildDatePicker(borderColor, boxBackgroundColor)),
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
                Icon(Icons.repeat, size: 16, color: _roundTrip ? Colors.teal.shade700 : Colors.grey,),
                SizedBox(width: 3,),
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
                  child: Transform.scale( // 스위치 크기 조절 위함
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
              '例: 250',
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

            _buildLabel('領収書/チケットアップロード', icon: Icons.receipt_long),
            GestureDetector(
              onTap: _pickImage,
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
                            color: Colors.teal.shade300,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
              ),
            ),

            const SizedBox(height: 36),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 제출 처리 로직 작성
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 56,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 6,
                  shadowColor: Colors.teal.shade300.withOpacity(0.5),
                ),
                child: const Text(
                  '提出する',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.shade100.withOpacity(0.7),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: Colors.teal.shade400),
            const SizedBox(width: 10),
            Text(
              '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.teal.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
