import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/transportation_provider.dart';

// ➊ ConsumerStatefulWidget 으로 변경
class TransportationScreen extends ConsumerStatefulWidget {
  const TransportationScreen({super.key});

  @override
  ConsumerState<TransportationScreen> createState() =>
      _TransportationScreenState();
}

// ➋ State → ConsumerState 로 변경
class _TransportationScreenState extends ConsumerState<TransportationScreen> {
  DateTime currentMonth = DateTime.now();

  late ScrollController _scrollController;
  bool isSummaryVisible = true;
  double _lastOffset = 0;

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

  void _scrollListener() {
    final offset = _scrollController.offset;

    if (offset <= 0) {
      // 스크롤 맨 위일 때 항상 보여줌
      if (!isSummaryVisible) {
        setState(() => isSummaryVisible = true);
      }
    } else if (offset > _lastOffset && isSummaryVisible) {
      // 아래로 스크롤 중 -> 숨김
      setState(() => isSummaryVisible = false);
    } else if (offset < _lastOffset && !isSummaryVisible) {
      // 위로 스크롤 중 -> 다시 표시
      setState(() => isSummaryVisible = true);
    }

    _lastOffset = offset;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ➌ Riverpod provider 구독
    final transportationAsync = ref.watch(transportationProvider(currentMonth));
    // final ym = DateFormat('yyyy年 MM月').format(currentMonth); // 7월이면 07월이됨
    final ym = '${currentMonth.year}年 ${currentMonth.month}月';

    // 이번 달 데이터 필터링
    final monthData =
        commuteData.where((item) {
          final itemDate = DateTime.tryParse(item['date'] ?? '');
          return itemDate != null &&
              itemDate.year == currentMonth.year &&
              itemDate.month == currentMonth.month;
        }).toList();

    final teikikenList =
        monthData.where((item) => item['type'] == '定期券').toList();

    final koutsuuhiList =
        monthData.where((item) => item['type'] == '交通費').toList();

    final teikikenTotal = teikikenList.fold<num>(
      0,
      (sum, item) => sum + item['amount'],
    );
    final koutsuuhiTotal = koutsuuhiList.fold<num>(
      0,
      (sum, item) => sum + item['amount'],
    );
    final grandTotal = teikikenTotal + koutsuuhiTotal;

    return transportationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('에러 발생: $e')),
      data: (transportationItem) {
        // transportationItem에서 "commute" 타입 필터링
        final commuteList =
            transportationItem
                .where((item) => item.expenseType == 'commute')
                .toList();

        print('commuteList : $commuteList');

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
                  onPressed:
                      () => setState(() => currentMonth = DateTime.now()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ), // 👈 요게 핵심! (터치 시 회색/물결 효과 제거)
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      // gradient: const LinearGradient(
                      //   colors: [Color(0xFF81C784), Color(0xFF4DB6AC)],
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      // ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      // constraints: const BoxConstraints(
                      //   minWidth: 50,
                      //   minHeight: 30,
                      // ),
                      child: const Text(
                        '今月',
                        style: TextStyle(
                          color: Color(0xFF00449e),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
              ),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // 월 이동 Row
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(16),
                  //   border: Border.all(color: const Color(0xFFBBDEFB), width: 1),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 이전 달 버튼 (내부 그라데이션 유지, 주변 그림자 제거)
                      ElevatedButton(
                        onPressed: () => moveMonth(-1),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ), // 👈 요게 핵심! (터치 시 회색/물결 효과 제거)
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
                            constraints: const BoxConstraints(
                              minWidth: 54,
                              minHeight: 26,
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
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
                            constraints: const BoxConstraints(
                              minWidth: 54,
                              minHeight: 26,
                            ),
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

                // 합계 영역
                Visibility(
                  visible: isSummaryVisible,
                  replacement: const SizedBox.shrink(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // color: Color(0xFFd8d8d8),
                          // border: Border.all(
                          // color: Color(0xFF37474F),
                          // ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8), // 회색 그림자
                              blurRadius: 8,
                              offset: Offset(3, 4), // 👉 오른쪽 3, 아래 4 픽셀로 그림자 위치
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_number,
                                  color: Color(0xFF81C784),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '定期券(${teikikenList.length}件)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black,
                                      // color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ),
                                Text(
                                  '￥$teikikenTotal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF81C784),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_bus,
                                  color: Color(0xFFFFB74D),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '交通費(${koutsuuhiList.length}件)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black,
                                      // color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                                Text(
                                  '￥$koutsuuhiTotal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFFFB74D),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 10,
                              thickness: 1,
                              color: Colors.black54,
                              // color: Color(0xFF2E7D32),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  color: Color(0xFF37474F),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    '総合計',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      // color: Color(0xFF004D40),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Text(
                                  '￥$grandTotal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF37474F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // 신청 내역들 영역 (스크롤 가능)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(), // ← 바운스 제거
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 정기권 신청 내역
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_number,
                                  color: Color(0xFF81C784),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '定期券申請履歴',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    // color: Color(0xFF004D40),
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (teikikenList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: const Text(
                              '申請履歴がありません。',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ListView.builder(
                            //shrinkWrap: true를 주면 ListView가 자식 위젯 크기에 맞춰 높이를 최소로 잡아줌
                            // 대신 성능은 약간 떨어질 수 있으니 리스트 아이템 수가 많지 않을 때 권장
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // 스크롤 안 되도록 (SingleChildScrollView 내에 있으므로)
                            itemCount: commuteList.length,
                            // transportationAsync 리스트에서  expenseType이 타입이 "commute"인 것만 그 길이
                            itemBuilder: (context, index) {
                              final item = commuteList[index];
                              final parsedDate = DateTime.tryParse(
                                item.updatedAt,
                              );
                              final dateText =
                                  parsedDate != null
                                      ? DateFormat('MM/dd').format(parsedDate)
                                      : '-';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(1, 2),
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
                                          color: Color(0xFF81C784),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${commuteList[index].fromStation}~${commuteList[index].toStation}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '￥${formatCurrency(commuteList[index].amount)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF81C784),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.date_range,
                                          size: 16,
                                          color: Color(0xFFfe673e),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '申請日：$dateText',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF515151),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.timelapse,
                                          size: 16,
                                          color: Color(0xFFfa6a23),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          formatCommuteDuration(commuteList[index].commuteDuration),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF515151),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 30),

                        // 교통비 신청 내역
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: Color(0xFFFFB74D),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '交通費申請履歴',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                // color: Color(0xFFBF360C),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (koutsuuhiList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: const Text(
                              '申請履歴がありません。',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...koutsuuhiList.map((item) {
                            final parsedDate = DateTime.tryParse(
                              item['date'] ?? '',
                            );
                            final dateText =
                                parsedDate != null
                                    ? DateFormat('MM/dd').format(parsedDate)
                                    : '-';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(1, 2),
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
                                        color: Color(0xFFFFB74D),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${item['from']} → ${item['to']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '￥${item['amount']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFB74D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range,
                                        size: 16,
                                        color: Color(0xFFfe673e),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '申請日：$dateText',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF515151),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Color(0xFF5b0075),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['reason'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF515151),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 10),
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
                          foregroundColor: const Color(0xFF004D40),
                          backgroundColor: const Color(0xFF81C784),
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
                          foregroundColor: const Color(0xFFBF360C),
                          backgroundColor: const Color(0xFFFFB74D),
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
      },
    );
  }
}


String formatCommuteDuration(String? duration) {
  switch (duration) {
    case '1m':
      return '１ヶ月';
    case '3m':
      return '３ヶ月';
    case '6m':
      return '６ヶ月';
    default:
      return '-';
  }
}


String formatCurrency(int amount) {
  final formatter = NumberFormat('#,###');
  return formatter.format(amount);
}