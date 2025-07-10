import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  DateTime currentMonth = DateTime.now();

  List<Map<String, dynamic>> commuteData = [
    {
      'type': '定期券',
      'amount': 12000,
      'date': '2025-07-05',
      'section': '池袋〜秋葉原',
      'duration': '1ヶ月分',
    },
    {
      'type': '交通費',
      'amount': 380,
      'date': '2025-07-07',
      'from': '渋谷',
      'to': '新宿',
      'reason': '打ち合わせのため',
    },
    {
      'type': '交通費',
      'amount': 380,
      'date': '2025-07-07',
      'from': '渋谷',
      'to': '新宿',
      'reason': '打ち合わせのため',
    },
  ];

  void moveMonth(int diff) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + diff);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ym = DateFormat('yyyy年 MM月').format(currentMonth);

    // 이번 달 데이터 필터링
    final monthData = commuteData.where((item) {
      final itemDate = DateTime.tryParse(item['date'] ?? '');
      return itemDate != null &&
          itemDate.year == currentMonth.year &&
          itemDate.month == currentMonth.month;
    }).toList();

    final teikikenList = monthData.where((item) => item['type'] == '定期券').toList();

    final koutsuuhiList = monthData.where((item) => item['type'] == '交通費').toList();

    final teikikenTotal = teikikenList.fold<num>(0, (sum, item) => sum + item['amount']);
    final koutsuuhiTotal = koutsuuhiList.fold<num>(0, (sum, item) => sum + item['amount']);
    final grandTotal = teikikenTotal + koutsuuhiTotal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
            },
            tooltip: '戻る',
            color: Colors.black87,
          ),
        ),
        title: const Text(
          '交通費・定期券',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: () => setState(() => currentMonth = DateTime.now()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),

              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFF4DB6AC)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(minWidth: 55, minHeight: 36),
                    child: const Text(
                      '今月',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 1,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // 월 이동 Row
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFBBDEFB),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 이전 달 버튼 (내부 그라데이션 유지, 주변 그림자 제거)
                  ElevatedButton(
                    onPressed: () => moveMonth(-1),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minWidth: 64, minHeight: 36),
                        child: const Text(
                          '前月',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 1,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 현재 연월 텍스트
                  Text(
                    ym,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  // 다음 달 버튼 (내부 그라데이션 유지, 주변 그림자 제거)
                  ElevatedButton(
                    onPressed: () => moveMonth(1),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minWidth: 64, minHeight: 36),
                        child: const Text(
                          '次月',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 1,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 신청 내역들 영역 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 정기권 신청 내역
                    const Text(
                      '定期券申請履歴',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3949AB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (teikikenList.isEmpty)
                      const Text(
                        '申請履歴がありません',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...teikikenList.map((item) {
                        final parsedDate = DateTime.tryParse(item['date'] ?? '');
                        final dateText =
                        parsedDate != null ? DateFormat('MM/dd').format(parsedDate) : '-';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.confirmation_number,
                                    color: Color(0xFF3949AB),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item['type'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF3949AB),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '￥${item['amount'] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '申請日：$dateText',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '区間：${item['section'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '期間：${item['duration'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 30),

                    // 교통비 신청 내역
                    const Text(
                      '交通費申請履歴',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (koutsuuhiList.isEmpty)
                      const Text(
                        '申請履歴がありません',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...koutsuuhiList.map((item) {
                        final parsedDate = DateTime.tryParse(item['date'] ?? '');
                        final dateText =
                        parsedDate != null ? DateFormat('MM/dd').format(parsedDate) : '-';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_bus,
                                    color: Color(0xFF1E88E5),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item['type'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '￥${item['amount'] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF3949AB),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '申請日：$dateText',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '出発：${item['from'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '到着：${item['to'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '理由：${item['reason'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 30),

                    // 합계 영역
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF0D8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '定期券 合計：￥$teikikenTotal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF33691E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '交通費 合計：￥$koutsuuhiTotal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const Divider(
                            height: 20,
                            thickness: 1,
                            color: Colors.green,
                          ),
                          Text(
                            '総合計：￥$grandTotal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF004D40),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50), // 버튼과의 간격
                  ],
                ),
              ),
            ),

            // 신청 버튼 2개
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 정기권 신청 화면 이동 처리
                    },
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: const Text('定期券 申請'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7986CB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 교통비 신청 화면 이동 처리
                    },
                    icon: const Icon(Icons.directions_bus_outlined),
                    label: const Text('交通費 申請'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64B5F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }
}
