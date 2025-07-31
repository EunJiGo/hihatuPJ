import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/commuter_screen.dart';
import 'package:hihatu_project/apply/transportations/transportation/data/fetch_transportation_submit.dart';
import 'package:hihatu_project/apply/transportations/transportation/presentation/detail/transportation_detail_screen.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_approval_status.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../tabbar/htt_tabbar.dart';
import '../../utils/dialog/attention_dialog.dart';
import '../../utils/dialog/success_dialog.dart';
import '../../utils/widgets/common_submit_buttons.dart';
import '../../utils/widgets/dropdown_option.dart';
import '../../utils/widgets/modals/dropdown_modal_widget.dart';
import '../remote/remote.dart';
import 'transportation/state/transportation_provider.dart';

// ➊ ConsumerStatefulWidget 으로 변경
class TransportationScreen extends ConsumerStatefulWidget {
  const TransportationScreen({super.key});

  @override
  ConsumerState<TransportationScreen> createState() =>
      _TransportationScreenState();
}

// ➋ State → ConsumerState 로 변경
class _TransportationScreenState extends ConsumerState<TransportationScreen>
    with SingleTickerProviderStateMixin {
  DateTime currentMonth = DateTime.now();

  late ScrollController _scrollController;
  bool isSummaryVisible = true;
  double _lastOffset = 0;

  AnimationController? _animationController;

  bool showCommuteList = true;
  bool showSingleList = true;

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
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // 한 바퀴 도는 데 걸리는 시간
      vsync: this,
    )..repeat(); // 무한 반복 회전
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ➌ Riverpod provider 구독
    final transportationAsync = ref.watch(transportationProvider(currentMonth));
    // final ym = DateFormat('yyyy年 MM月').format(currentMonth); // 7월이면 07월이됨
    final ym = '${currentMonth.year}年 ${currentMonth.month}月';

    // 데이터 있을 때 UI (원래 your data 처리 코드)
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HHTTabbar(initialIndex: 3),
                ),
                (Route<dynamic> route) => false,
              );
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

      body: Builder(
        builder: (context) {
          if (transportationAsync.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF42A5F5)),
            );
          }

          if (transportationAsync.hasError) {
            return Center(child: Text('エラー発生: ${transportationAsync.error}'));
          }

          if (!transportationAsync.hasValue ||
              transportationAsync.value == null) {
            return const Center(child: Text('データが存在しません'));
          }

          final transportationItem = transportationAsync.value!;

          // transportationItem에서 "commute" 타입 필터링
          // 정기권
          final commuteList =
              transportationItem
                  .where((item) => item.expenseType == 'commute')
                  .toList();

          final commuteTotal = commuteList.fold(
            0,
            (sum, item) => sum + item.amount, //
          );

          // 교통비
          final singleList =
              transportationItem
                  .where((item) => item.expenseType == 'single')
                  .toList();

          final singleTotal = singleList.fold(
            0,
            (sum, item) => sum + item.amount,
          );

          final grandTotal = commuteTotal + singleTotal;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // 월 이동 Row
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
                              color: Colors.grey.withOpacity(0.8),
                              // 회색 그림자
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
                                    '定期券(${commuteList.length}件)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black,
                                      // color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ),
                                Text(
                                  '￥${formatCurrency(commuteTotal)}',
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
                                    '交通費(${singleList.length}件)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black,
                                      // color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                                Text(
                                  '￥${formatCurrency(singleTotal)}',
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
                                  '￥${formatCurrency(grandTotal)}',
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                StatusExplanation(),

                const SizedBox(height: 10),

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
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    showCommuteList
                                        ? Icons.keyboard_arrow_down_rounded
                                        : Icons.keyboard_arrow_up_rounded,
                                    color: Colors.grey.shade700,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showCommuteList = !showCommuteList;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (commuteList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: const Text(
                              '申請履歴がありません。',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else if (showCommuteList)
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

                              return GestureDetector(
                                onTap: () {
                                  print('commute ID: ${item.id}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => CommuterScreen(
                                            commuteId: item.id,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.confirmation_number,
                                            color: Color(0xFF81C784),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            commuteList[index].fromStation,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(Icons.remove_rounded, size: 15),
                                          const SizedBox(width: 5),
                                          Text(
                                            commuteList[index].toStation,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Text(
                                                '￥',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  // color: Color(0xFF282828),
                                                  color: Color(0xFF81C784),
                                                ),
                                              ),
                                              Text(
                                                formatCurrency(
                                                  commuteList[index].amount,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF424242),
                                                  // color: Color(0xFF81C784),
                                                ),
                                              ),
                                            ],
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
                                            formatCommuteDuration(
                                              commuteList[index]
                                                  .commuteDuration,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF515151),
                                            ),
                                          ),
                                          const Spacer(),
                                          getStatusIcon(
                                            commuteList[index].submissionStatus,
                                            commuteList[index].reviewStatus,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                showSingleList
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                color: Colors.grey.shade700,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  showSingleList = !showSingleList;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (singleList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: const Text(
                              '申請履歴がありません。',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else if (showSingleList)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // 스크롤 안 되도록 (SingleChildScrollView 내에 있으므로)
                            itemCount: singleList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = singleList[index];
                              final parsedDate = DateTime.tryParse(
                                item.updatedAt,
                              );
                              final dateText =
                                  parsedDate != null
                                      ? DateFormat('MM/dd').format(parsedDate)
                                      : '-';

                              return GestureDetector(
                                onTap: () {
                                  print('single ID: ${item.id}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => TransportationInputScreen(
                                            transportationId: item.id,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.directions_bus,
                                            color: Color(0xFFFFB74D),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            singleList[index].fromStation,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          singleList[index].twice
                                              ? Icon(
                                                Icons.repeat,
                                                size: 20,
                                                color: Color(0xFF0125f3),
                                              )
                                              : Icon(
                                                Icons.arrow_right_alt,
                                                size: 18,
                                                color: Color(0xFFf30101),
                                              ),
                                          const SizedBox(width: 8),
                                          Text(
                                            singleList[index].toStation,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Text(
                                                '￥',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  // color: Color(0xFF282828),
                                                  color: Color(0xFFFFB74D),
                                                ),
                                              ),
                                              Text(
                                                formatCurrency(
                                                  singleList[index].amount,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF424242),
                                                  // color: Color(0xFF81C784),
                                                ),
                                              ),
                                            ],
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
                                          Text(
                                            singleList[index].goals ?? '-',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF515151),
                                            ),
                                          ),
                                          const Spacer(),
                                          getStatusIcon(
                                            singleList[index].submissionStatus,
                                            singleList[index].reviewStatus,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // 신청버튼 / 제출버튼
                CommonSubmitButtons(
                  onSavePressed: () {
                    final options = [
                      DropdownOption.fromText(
                        '定期券申請',
                        icon: Icons.confirmation_number,
                        iconColor: Color(0xFF81C784),
                      ),
                      DropdownOption.fromText(
                        '交通費申請',
                        icon: Icons.directions_bus,
                        iconColor: Color(0xFFFFB74D),
                      ),
                      DropdownOption.fromText(
                        '在宅勤務手当',
                        icon: FontAwesomeIcons.houseLaptop,
                        iconColor: Color(0xFFfeaaa9),
                      ),
                    ];

                    // 申請 버튼 클릭 시 로직
                    DropdownModalWidget.show(
                      context: context,
                      options: options,
                      selectedValue: null,
                      onSelected: (val) {
                        if (val == '定期券申請') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CommuterScreen(),
                            ),
                          );
                        } else if (val == '交通費申請') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransportationInputScreen(),
                            ),
                          );
                        } else if (val == '在宅勤務手当') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RemoteScreen(),
                            ),
                          );
                        }
                      },
                      selectedTextColor: const Color(0xFF1565C0),
                      selectedIconColor: Colors.blueAccent,
                      selectedBorderColor: const Color(0xFF64B5F6),
                      selectedBackgroundColor: const Color(0xFFE3F2FD),
                    );
                  },
                  onSubmitPressed: () async {
                    // 提出 버튼 클릭 시 로직
                    final finalSuccess = await fetchTransportationSubmit(
                      'admins',
                      currentMonth,
                    );

                    if (finalSuccess) {
                      await successDialog(context, '申請完了', '交通費申請を完了しました。');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransportationScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      attentionDialog(context, '登録エラー', '交通費申請が失敗しました。');
                    }
                  },
                  saveText: '申　請',
                  submitText: '提　出',
                  submitConfirmMessage: '提出しますか？\n提出したら、修正ができないです。',
                  padding: 0,
                  // 원하는 여백
                  themeColor: const Color(0xFF0253B3), // 기본색 그대로 사용
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }

  Widget getStatusIcon(String submissionStatus, String reviewStatus) {
    final icon = getStatusText(submissionStatus, reviewStatus);

    if (submissionStatus == 'draft') {
      // return Transform.rotate(
      //   angle: math.pi / 4, // 45도 회전
      //   child: icon,
      // );
      // return AnimatedBuilder(
      //   animation: _animationController!,
      //   builder: (context, child) {
      //     // // -45도 ~ +45도 사이를 왔다갔다
      //     // final angle = math.sin(_animationController!.value * 2 * math.pi) * (math.pi / 4);
      //     // 좌우로 20도만 흔들기 => 20도 = pi / 9  // 36은 5도
      //     final angle = math.sin(_animationController!.value * 2 * math.pi) * (math.pi / 56);
      //     return Transform.rotate(
      //       angle: angle,
      //       child: icon,
      //     );
      //   },
      // );
      return AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) {
          // sin 곡선을 이용한 좌우 이동 (5px)
          // math.sin(...) : 왔다갔다 반복
          // * 4 : 진폭. 너무 크면 2~3으로 줄여도 돼요.
          // Offset(dx, 0) : x축 이동만 (좌우로)
          final dx = math.sin(_animationController!.value * 2 * math.pi) * 2;
          return Transform.translate(offset: Offset(dx, dx), child: icon);
        },
      );
    }

    if (submissionStatus == 'submitted' && reviewStatus == 'pending') {
      return RotationTransition(
        turns: _animationController ?? AlwaysStoppedAnimation(0),
        child: icon,
      );
    }

    return icon;
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

String formatCurrency(int? amount) {
  final formatter = NumberFormat('#,###');
  return formatter.format(amount) ?? '';
}

// 상태에 따라 텍스트와 색상을 반환하는 함수
Icon getStatusText(String submissionStatus, String reviewStatus) {
  if (submissionStatus == 'draft') {
    return const Icon(Icons.edit, color: Color(0xFF616161), size: 18); // 임시 저장
  }

  if (submissionStatus == 'submitted') {
    if (reviewStatus == 'pending') {
      return const Icon(
        Icons.hourglass_top,
        color: Color(0xFFeece01),
        size: 18,
      ); // 확인 중
    }
    if (reviewStatus == 'approved') {
      return const Icon(
        Icons.check_circle_outline,
        color: Color(0xFF33A1FD),
        size: 18,
      ); // 승인됨
    }
    if (reviewStatus == 'returned') {
      return const Icon(
        Icons.cancel_outlined,
        color: Color(0xFFE53935),
        size: 18,
      ); // 반려
    }
  }

  // 그 외 알 수 없는 상태
  return const Icon(Icons.help_outline, color: Colors.grey, size: 18);
}
