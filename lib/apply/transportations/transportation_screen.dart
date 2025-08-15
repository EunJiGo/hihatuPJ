import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/transportations/commuter/presentation/commuter_screen.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/remote_and_other_history.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_history_list.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_title_section.dart';
import 'package:hihatu_project/apply/transportations/transportation/data/fetch_transportation_submit.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_item.dart';
import 'package:hihatu_project/apply/transportations/transportation/presentation/detail/transportation_detail_screen.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_approval_status.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/rendering.dart' show RenderBox;

import '../../tabbar/htt_tabbar.dart';
import '../../utils/dialog/attention_dialog.dart';
import '../../utils/dialog/confirmation_dialog.dart';
import '../../utils/dialog/success_dialog.dart';
import '../../utils/widgets/common_submit_buttons.dart';
import '../../utils/widgets/dropdown_option.dart';
import '../../utils/widgets/modals/dropdown_modal_widget.dart';
import '../others/other_expense_screen.dart';
import '../remote/remoteScreen.dart';
import 'transportation/state/transportation_provider.dart';

// ➊ ConsumerStatefulWidget 으로 변경
class TransportationScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const TransportationScreen({super.key, required this.initialDate});

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
  double _lastOffset = 0.0;
  double _dirAccum = 0.0;
  static const double _toggleThreshold = 14.0;     // 토글 임계치
  static const double _topStickyThreshold = 46.0;  // 맨 위 고정 임계치
  final _summaryKey = GlobalKey();
  double get _summaryHeight {
    final box = _summaryKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size.height ?? 0;
  }


  AnimationController? _animationController;

  bool showCommuteList = true;
  bool showSingleList = true;
  bool showRemote = true;
  bool showOtherExpenseList = true;

  void _ensureSummaryVisibleIfCantScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final canScroll = _scrollController.position.maxScrollExtent > 0;
      if (!canScroll && !isSummaryVisible) {
        setState(() {
          isSummaryVisible = true;
          _dirAccum = 0;
          _lastOffset = _scrollController.position.pixels;
        });
      }
    });
  }
  

  void moveMonth(int diff) {
    final newMonth = DateTime(currentMonth.year, currentMonth.month + diff);
    setState(() {
      currentMonth = newMonth;
    });
    ref.invalidate(transportationProvider(newMonth));
    _ensureSummaryVisibleIfCantScroll(); // ← 추가
  }

  // double _lastOffset = 0.0;


  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final pos = _scrollController.position;
    final offset = pos.pixels;

    // 1) 콘텐츠가 화면보다 짧으면: 합계 항상 표시 + 상태 리셋
    if (pos.maxScrollExtent <= 0) {
      if (!isSummaryVisible) setState(() => isSummaryVisible = true);
      _lastOffset = offset;
      _dirAccum = 0;
      return;
    }

    // 2) 맨 위 근처에서는 항상 표시 + 상태 리셋(바운스/미세 이동 차단)
    if (offset < _topStickyThreshold) {
      if (!isSummaryVisible) setState(() => isSummaryVisible = true);
      _lastOffset = offset;
      _dirAccum = 0;
      return;
    }

    // 3) 이동량 계산 (노이즈 무시)
    final delta = offset - _lastOffset;
    if (delta == 0) return;

    // 4) 같은 방향 누적, 방향 바뀌면 리셋
    if ((delta > 0 && _dirAccum >= 0) || (delta < 0 && _dirAccum <= 0)) {
      _dirAccum += delta;
    } else {
      _dirAccum = delta;
    }

    // 5) 숨기기 전 가드: 숨긴 뒤에도 스크롤이 남는지 확인
    const double remainMargin = 0.0; // 필요하면 8.0 등 여유값
    final bool summaryMeasured = _summaryHeight > 0;
    final bool willBeScrollableAfterHide = summaryMeasured
        ? (pos.maxScrollExtent - _summaryHeight) > remainMargin
        : false; // 높이 미측정이면 숨기지 않음

    // 6) 임계치 넘을 때만 토글(히스테리시스)
    if (_dirAccum > _toggleThreshold && isSummaryVisible) {
      if (willBeScrollableAfterHide) {
        setState(() => isSummaryVisible = false);
      }
      _dirAccum = 0; // 토글했든 말았든 누적은 리셋
    } else if (_dirAccum < -_toggleThreshold && !isSummaryVisible) {
      setState(() => isSummaryVisible = true);
      _dirAccum = 0;
    }

    _lastOffset = offset;
  }







  // void _scrollListener() {
  //   final offset = _scrollController.offset;
  //
  //   if (offset <= 0) {
  //     // 스크롤 맨 위일 때 항상 보여줌
  //     if (!isSummaryVisible) {
  //       setState(() => isSummaryVisible = true);
  //     }
  //   } else if (offset > _lastOffset && isSummaryVisible) {
  //     // 아래로 스크롤 중 -> 숨김
  //     setState(() => isSummaryVisible = false);
  //   } else if (offset < _lastOffset && !isSummaryVisible) {
  //     // 위로 스크롤 중 -> 다시 표시
  //     setState(() => isSummaryVisible = true);
  //   }
  //
  //   _lastOffset = offset;
  // }

  @override
  void initState() {
    super.initState();
    currentMonth = widget.initialDate;
    print('currentMonth : $currentMonth');
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
    print('build');
    _ensureSummaryVisibleIfCantScroll();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollController.hasClients) {
    //     final canScroll = _scrollController.position.maxScrollExtent > 0;
    //     if (!canScroll && !isSummaryVisible) {
    //       setState(() => isSummaryVisible = true);
    //     }
    //   }
    // });

    // ➌ Riverpod provider 구독
    final transportationAsync = ref.watch(transportationProvider(currentMonth));
    // final ym = DateFormat('yyyy年 MM月').format(currentMonth); // 7월이면 07월이됨
    final ym = '${currentMonth.year}年 ${currentMonth.month}月';


    // ❌ final transportationItem = transportationAsync.value!;
    // ✅ 안전한 가져오기
    final List<TransportationItem> transportationItem =
        transportationAsync.asData?.value ?? const <TransportationItem>[];

    // transportationItem에서 "commute" 타입 필터링
    // 정기권
    final commuteList = transportationItem
        .where((item) => item.expenseType == 'commute')
        .toList();

    final commuteTotal = commuteList.fold(
      0,
          (sum, item) => sum + item.amount,
    );

    // 교통비
    final singleList = transportationItem
        .where((item) => item.expenseType == 'single')
        .toList();

    final singleTotal = singleList.fold(
      0,
          (sum, item) => sum + item.amount,
    );

    // 재택근무수당 -> 당월에 한개밖에 없음
    final remoteList = transportationItem
        .where((item) => item.expenseType == 'home_office_expenses')
        .toList();

    final TransportationItem? remote = remoteList.isNotEmpty
        ? remoteList.first
        : null;

    final remoteTotal = remote?.amount ?? 0;

    // 그 외 경비
    final otherExpenseList = transportationItem
        .where((item) => item.expenseType == 'travel')
        .toList();

    final otherExpenseTotal = otherExpenseList.fold(
      0,
          (sum, item) => sum + item.amount,
    );

    final grandTotal =
        commuteTotal + singleTotal + remoteTotal + otherExpenseTotal;

    // body 안의 Builder 또는 SingleChildScrollView 근처에서:
    final scaffoldState = Scaffold.maybeOf(context);
    final hasBottomBar = scaffoldState?.widget.bottomNavigationBar != null;



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
          '交通費・立替金',
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
              // onPressed: () => setState(() => currentMonth = DateTime.now()),
              onPressed: () {
                final now = DateTime.now();
                final thisMonth = DateTime(now.year, now.month);

                if (currentMonth.year != thisMonth.year || currentMonth.month != thisMonth.month) {
                  setState(() => currentMonth = thisMonth);
                  ref.invalidate(transportationProvider(thisMonth));
                } else {
                  // 현재 월과 같더라도 강제로 invalidate
                  ref.invalidate(transportationProvider(thisMonth));
                }
              },
              style:
                  ElevatedButton.styleFrom(
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
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  alignment: Alignment.center,
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

//           final transportationItem = transportationAsync.value!;
//
//           // transportationItem에서 "commute" 타입 필터링
//           // 정기권
//           final commuteList = transportationItem
//               .where((item) => item.expenseType == 'commute')
//               .toList();
//
//           final commuteTotal = commuteList.fold(
//             0,
//             (sum, item) => sum + item.amount,
//           );
//
//           // 교통비
//           final singleList = transportationItem
//               .where((item) => item.expenseType == 'single')
//               .toList();
//
//           final singleTotal = singleList.fold(
//             0,
//             (sum, item) => sum + item.amount,
//           );
//
//           // 재택근무수당 -> 당월에 한개밖에 없음
//           final remoteList = transportationItem
//               .where((item) => item.expenseType == 'home_office_expenses')
//               .toList();
//
//           final TransportationItem? remote = remoteList.isNotEmpty
//               ? remoteList.first
//               : null;
//
//           final remoteTotal = remote?.amount ?? 0;
//
//           // 그 외 경비
//           final otherExpenseList = transportationItem
//               .where((item) => item.expenseType == 'travel')
//               .toList();
//
//           final otherExpenseTotal = otherExpenseList.fold(
//             0,
//             (sum, item) => sum + item.amount,
//           );
//
//           final grandTotal =
//               commuteTotal + singleTotal + remoteTotal + otherExpenseTotal;
//
//           // body 안의 Builder 또는 SingleChildScrollView 근처에서:
//           final scaffoldState = Scaffold.maybeOf(context);
//           final hasBottomBar = scaffoldState?.widget.bottomNavigationBar != null;
//
// // CommonSubmitButtons 예상 높이(프로젝트 위젯에 맞게 조정)
//           const double actionBarHeight = 72.0;
// // 마지막 아이템과 바 사이 여유
//           const double extraSpacing = 16.0;
//           final double safeBottom = MediaQuery.of(context).padding.bottom;
//
//           final double bottomPad = hasBottomBar
//               ? actionBarHeight + safeBottom + extraSpacing
//               : 16.0;

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
                        style:
                            ElevatedButton.styleFrom(
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
                        style:
                            ElevatedButton.styleFrom(
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

                // 합계 영역, 제출상황, 승인상태
                if (commuteList.isNotEmpty ||
                    singleList.isNotEmpty ||
                    remoteList.isNotEmpty ||
                    otherExpenseList.isNotEmpty) ...[
                  // 합계 영역
                  Visibility(
                    visible: isSummaryVisible,
                    replacement: const SizedBox.shrink(),
                    child: Column(
                      children: [
                        Container(
                          key: _summaryKey,
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
                                offset: Offset(
                                  3,
                                  4,
                                ), // 👉 오른쪽 3, 아래 4 픽셀로 그림자 위치
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (commuteList.isNotEmpty) ...[
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
                                const SizedBox(height: 10),
                              ],
                              if (singleList.isNotEmpty) ...[
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
                                const SizedBox(height: 10),
                              ],
                              if (remoteList.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.houseLaptop,
                                      color: Color(0xFFfeaaa9),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '在宅勤務手当(${remoteList.length}件)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                          // color: Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '￥${formatCurrency(remoteTotal)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFfeaaa9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                              if (otherExpenseList.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      color: Color(0xFF89e6f4),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '立替金(${otherExpenseList.length}件)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                          // color: Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '￥${formatCurrency(otherExpenseTotal)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF89e6f4),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],

                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.black54,
                                // color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(height: 10),
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
                  // 제출상황, 승인상태
                  StatusExplanation(),

                  const SizedBox(height: 10),

                  // 신청 내역들 영역 (스크롤 가능)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(), // 안드로이드 튕김 없음
                      ),

                      // physics: const ClampingScrollPhysics(), // ← 바운스 제거
                      // padding: EdgeInsets.only(
                      //   bottom: 448 + MediaQuery.of(context).padding.bottom + 12,
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 정기권 신청 내역
                          if (commuteList.isNotEmpty) ...[
                            TransportationTitleSection(
                              icon: Icons.confirmation_number,
                              iconColor: Color(0xFF81C784),
                              title: '定期券の申請履歴',
                              isExpanded: showCommuteList,
                              isData: commuteList.isEmpty,
                              onToggle: () {
                                setState(
                                  () => showCommuteList = !showCommuteList,
                                );
                                _ensureSummaryVisibleIfCantScroll();
                              },
                            ),

                            if (showCommuteList)
                              TransportationHistoryList(
                                items: commuteList
                                    .map(
                                      (item) => TransportationUiItem(
                                        id: item.id!,
                                        fromStation: item.fromStation,
                                        toStation: item.toStation,
                                        amount: item.amount,
                                        isCommuter: true,
                                        twice: false,
                                        updatedAt: item.updatedAt,
                                        commuteDuration: item.commuteDuration,
                                        submissionStatus: item.submissionStatus,
                                        reviewStatus: item.reviewStatus,
                                      ),
                                    )
                                    .toList(),
                                onTap: (id) async {
                                  final result =
                                      await Navigator.push<DateTime?>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CommuterScreen(commuteId: id),
                                        ),
                                      );

                                  if (result != null) {
                                    setState(() {
                                      currentMonth = DateTime(
                                        result.year,
                                        result.month,
                                      );
                                    });
                                    ref.invalidate(
                                      transportationProvider(currentMonth),
                                    );
                                  }
                                },

                                getStatusIcon: getStatusIcon,

                                // 🎨 스타일
                                leadingIcon: Icons.confirmation_number,
                                leadingIconColor: Color(0xFF81C784),
                                amountColor: Color(0xFF81C784),
                                separatorIconColor: Colors.black54,
                              ),
                          ],

                          // 교통비 신청 내역
                          if (singleList.isNotEmpty) ...[
                            TransportationTitleSection(
                              icon: Icons.directions_bus,
                              iconColor: Color(0xFFFFB74D),
                              title: '交通費の申請履歴',
                              isExpanded: showSingleList,
                              isData: singleList.isEmpty,
                              onToggle: () {
                                setState(
                                  () => showSingleList = !showSingleList,
                                );
                                _ensureSummaryVisibleIfCantScroll();
                              },
                            ),
                            if (showSingleList)
                              TransportationHistoryList(
                                items: singleList
                                    .map(
                                      (item) => TransportationUiItem(
                                        id: item.id!,
                                        fromStation: item.fromStation,
                                        toStation: item.toStation,
                                        amount: item.amount,
                                        isCommuter: false,
                                        twice: item.twice,
                                        updatedAt: item.updatedAt,
                                        goals: item.goals,
                                        submissionStatus: item.submissionStatus,
                                        reviewStatus: item.reviewStatus,
                                      ),
                                    )
                                    .toList(),
                                onTap: (id) async {
                                  final result =
                                      await Navigator.push<DateTime?>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TransportationInputScreen(
                                                transportationId: id,
                                              ),
                                        ),
                                      );

                                  if (result != null) {
                                    setState(() {
                                      currentMonth = DateTime(
                                        result.year,
                                        result.month,
                                      );
                                    });
                                    ref.invalidate(
                                      transportationProvider(currentMonth),
                                    );
                                  }
                                },
                                getStatusIcon: getStatusIcon,

                                // 🎨 스타일
                                leadingIcon: Icons.directions_bus,
                                leadingIconColor: Color(0xFFFFB74D),
                                amountColor: Color(0xFFFFB74D),
                                separatorIconColor: Color(0xFFf30101),
                              ),
                          ],

                          // 재택 수당 신청 내역
                          if (remote != null) ...[
                            TransportationTitleSection(
                              icon: FontAwesomeIcons.houseLaptop,
                              iconColor: Color(0xFFfeaaa9),
                              iconSize: 22,
                              title: '在宅勤務手当の申請履歴',
                              isExpanded: showRemote,
                              isData: remoteList.isEmpty,
                              gap: 15,
                              onToggle: () {
                                setState(() => showRemote = !showRemote);
                                _ensureSummaryVisibleIfCantScroll();
                              },
                            ),

                            if (showRemote)
                              RemoteAndOtherItemHistoryList(
                                items: remoteList
                                    .map(
                                      (item) => RemoteAndOtherItem(
                                        id: item.id!,
                                        isRemote: true,
                                        amount: item.amount,
                                        updatedAt: item.updatedAt,
                                        goals: item.goals,
                                        submissionStatus: item.submissionStatus,
                                        reviewStatus: item.reviewStatus,
                                      ),
                                    )
                                    .toList(),
                                onTap: (id) async {
                                  final result =
                                      await Navigator.push<DateTime?>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RemoteScreen(
                                            transportationId: id,
                                          ),
                                        ),
                                      );

                                  if (result != null) {
                                    setState(() {
                                      currentMonth = DateTime(
                                        result.year,
                                        result.month,
                                      );
                                    });
                                    ref.invalidate(
                                      transportationProvider(currentMonth),
                                    );
                                  }
                                },
                                getStatusIcon: getStatusIcon,
                                leadingIcon: FontAwesomeIcons.houseLaptop,
                                leadingIconColor: Color(0xFFfeaaa9),
                                amountColor: Color(0xFFfeaaa9),
                                separatorIconColor: Color(0xFFf30101),
                              ),
                          ],

                          // 그 외 경비 신청 내역
                          if (otherExpenseList.isNotEmpty) ...[
                            TransportationTitleSection(
                              // icon: FontAwesomeIcons.sackDollar,
                              icon: Icons.receipt_long,
                              iconColor: Color(0xFF89e6f4),
                              iconSize: 25,
                              title: '立替金の申請履歴',
                              isExpanded: showOtherExpenseList,
                              isData: otherExpenseList.isEmpty,
                              gap: 8,
                              onToggle: () {
                                setState(
                                  () => showOtherExpenseList =
                                      !showOtherExpenseList,
                                );
                                _ensureSummaryVisibleIfCantScroll();
                              },
                            ),

                            if (showOtherExpenseList)
                              RemoteAndOtherItemHistoryList(
                                items: otherExpenseList
                                    .map(
                                      (item) => RemoteAndOtherItem(
                                        id: item.id!,
                                        isRemote: false,
                                        amount: item.amount,
                                        updatedAt: item.updatedAt,
                                        goals: item.goals,
                                        submissionStatus: item.submissionStatus,
                                        reviewStatus: item.reviewStatus,
                                      ),
                                    )
                                    .toList(),
                                onTap: (id) async {
                                  final result =
                                  await Navigator.push<DateTime?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OtherExpenseScreen(
                                            transportationId: id,
                                          ),
                                    ),
                                  );

                                  if (result != null) {
                                    setState(() {
                                      currentMonth = DateTime(
                                        result.year,
                                        result.month,
                                      );
                                    });
                                    ref.invalidate(
                                      transportationProvider(currentMonth),
                                    );
                                  }
                                },
                                getStatusIcon: getStatusIcon,
                                leadingIcon: Icons.receipt_long,
                                leadingIconColor: Color(0xFF89e6f4),
                                amountColor: Color(0xFF89e6f4),
                                separatorIconColor: Color(0xFFf30101),
                              ),
                          ],
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],

                // 합계 영역, 제출상황, 승인상태 없음
                if (commuteList.isEmpty &&
                    singleList.isEmpty &&
                    remoteList.isEmpty &&
                    otherExpenseList.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history, // 👈 아이콘 변경 가능
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '申請履歴がないです。\n交通費及び定期券を申請してください。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.5, // 줄 간격
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // 신청버튼 / 제출버튼
                // CommonSubmitButtons(
                //   onSavePressed: () {
                //     final options = [
                //       DropdownOption.fromText(
                //         '定期券申請',
                //         icon: Icons.confirmation_number,
                //         iconColor: Color(0xFF81C784),
                //       ),
                //       DropdownOption.fromText(
                //         '交通費申請',
                //         icon: Icons.directions_bus,
                //         iconColor: Color(0xFFFFB74D),
                //       ),
                //       DropdownOption.fromText(
                //         '在宅勤務手当申請',
                //         icon: FontAwesomeIcons.houseLaptop,
                //         iconColor: Color(0xFFfeaaa9),
                //       ),
                //       DropdownOption.fromText(
                //         '立替金申請',
                //         icon: Icons.receipt_long,
                //         iconColor: Color(0xFF89e6f4),
                //       ),
                //     ];
                //
                //     // 申請 버튼 클릭 시 로직
                //     DropdownModalWidget.show(
                //       context: context,
                //       options: options,
                //       selectedValue: null,
                //       onSelected: (val) async {
                //         if (val == '定期券申請') {
                //           final result = await Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (_) => const CommuterScreen(),
                //             ),
                //           );
                //           if (result != null && result is DateTime) {
                //             setState(() {
                //               currentMonth = DateTime(
                //                 result.year,
                //                 result.month,
                //               );
                //             });
                //             ref.invalidate(
                //               transportationProvider(currentMonth),
                //             );
                //           }
                //         } else if (val == '交通費申請') {
                //           final result = await Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (_) => const TransportationInputScreen(),
                //             ),
                //           );
                //           if (result != null && result is DateTime) {
                //             setState(() {
                //               currentMonth = DateTime(
                //                 result.year,
                //                 result.month,
                //               );
                //             });
                //             ref.invalidate(
                //               transportationProvider(currentMonth),
                //             );
                //           }
                //         } else if (val == '在宅勤務手当申請') {
                //           final result = await Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (_) => const RemoteScreen(),
                //             ),
                //           );
                //           if (result != null && result is DateTime) {
                //             setState(() {
                //               currentMonth = DateTime(
                //                 result.year,
                //                 result.month,
                //               );
                //             });
                //             ref.invalidate(
                //               transportationProvider(currentMonth),
                //             );
                //           }
                //         } else if (val == '立替金申請') {
                //           final result = await Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (_) => const OtherExpenseScreen(),
                //             ),
                //           );
                //           if (result != null && result is DateTime) {
                //             setState(() {
                //               currentMonth = DateTime(
                //                 result.year,
                //                 result.month,
                //               );
                //             });
                //             ref.invalidate(
                //               transportationProvider(currentMonth),
                //             );
                //           }
                //         }
                //       },
                //       selectedTextColor: const Color(0xFF1565C0),
                //       selectedIconColor: Colors.blueAccent,
                //       selectedBorderColor: const Color(0xFF64B5F6),
                //       selectedBackgroundColor: const Color(0xFFE3F2FD),
                //     );
                //   },
                //   onSubmitPressed: () async {
                //     // 提出 버튼 클릭 시 로직
                //
                //     // 신청내역이 없을 때
                //     if (commuteList.isEmpty &&
                //         singleList.isEmpty &&
                //         remoteList.isEmpty &&
                //         otherExpenseList.isEmpty) {
                //       attentionDialog(context, '注意', '申請内訳がありません。');
                //       return;
                //     }
                //
                //     // 전부 제출 상황일 떄(submission_status == submitted)
                //     final allItems = [...commuteList, ...singleList, ...remoteList, ...otherExpenseList];
                //     final isAllSubmitted = allItems.every((item) => item.submissionStatus == 'submitted');
                //
                //     if (isAllSubmitted) {
                //       attentionDialog(context, '注意', '既に申請内訳を全て提出しました。');
                //       return;
                //     }
                //
                //     // ✅ 신청 내역이 있을 때만 confirm 다이얼로그
                //     final confirmed = await ConfirmationDialog.show(
                //       context,
                //       message: '${currentMonth.year}年${currentMonth.month}月の申請内訳を提出しますか？\n提出したら、修正ができないです。',
                //     );
                //
                //     if (!confirmed!) return;
                //
                //
                //     final finalSuccess = await fetchTransportationSubmit(
                //       'admins',
                //       currentMonth,
                //     );
                //
                //     if (finalSuccess) {
                //       await successDialog(context, '一括提出完了', '${currentMonth.year}年${currentMonth.month}月の申請内訳を一括提出しました。');
                //
                //       // ✅ Provider 강제 갱신
                //       ref.invalidate(transportationProvider(currentMonth));
                //
                //       // Navigatorr.pushAndRemoveUntil(
                //       //   context,
                //       //   MaterialPageRoute(
                //       //     builder: (_) =>
                //       //         TransportationScreen(initialDate: currentMonth),
                //       //   ),
                //       //   (route) => false,
                //       // );
                //     } else {
                //       attentionDialog(context, 'エラー', '${currentMonth.year}年${currentMonth.month}月の申請内訳の一括提出を失敗しました。');
                //     }
                //   },
                //   saveText: '申　請',
                //   submitText: '一括提出',
                //   submitConfirmMessage: null,
                //   // submitConfirmMessage:
                //   //     '${currentMonth.year}年${currentMonth.month}月の申請内訳を提出しますか？\n提出したら、修正ができないです。',
                //   padding: 0,
                //   // 원하는 여백
                //   themeColor: const Color(0xFF0253B3), // 기본색 그대로 사용
                // ),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
          child: // 신청버튼 / 제출버튼
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
                  '在宅勤務手当申請',
                  icon: FontAwesomeIcons.houseLaptop,
                  iconColor: Color(0xFFfeaaa9),
                ),
                DropdownOption.fromText(
                  '立替金申請',
                  icon: Icons.receipt_long,
                  iconColor: Color(0xFF89e6f4),
                ),
              ];

              // 申請 버튼 클릭 시 로직
              DropdownModalWidget.show(
                context: context,
                options: options,
                selectedValue: null,
                onSelected: (val) async {
                  if (val == '定期券申請') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CommuterScreen(),
                      ),
                    );
                    if (result != null && result is DateTime) {
                      setState(() {
                        currentMonth = DateTime(
                          result.year,
                          result.month,
                        );
                      });
                      ref.invalidate(
                        transportationProvider(currentMonth),
                      );
                    }
                  } else if (val == '交通費申請') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransportationInputScreen(),
                      ),
                    );
                    if (result != null && result is DateTime) {
                      setState(() {
                        currentMonth = DateTime(
                          result.year,
                          result.month,
                        );
                      });
                      ref.invalidate(
                        transportationProvider(currentMonth),
                      );
                    }
                  } else if (val == '在宅勤務手当申請') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RemoteScreen(),
                      ),
                    );
                    if (result != null && result is DateTime) {
                      setState(() {
                        currentMonth = DateTime(
                          result.year,
                          result.month,
                        );
                      });
                      ref.invalidate(
                        transportationProvider(currentMonth),
                      );
                    }
                  } else if (val == '立替金申請') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OtherExpenseScreen(),
                      ),
                    );
                    if (result != null && result is DateTime) {
                      setState(() {
                        currentMonth = DateTime(
                          result.year,
                          result.month,
                        );
                      });
                      ref.invalidate(
                        transportationProvider(currentMonth),
                      );
                    }
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

              // 신청내역이 없을 때
              if (commuteList.isEmpty &&
                  singleList.isEmpty &&
                  remoteList.isEmpty &&
                  otherExpenseList.isEmpty) {
                attentionDialog(context, '注意', '申請内訳がありません。');
                return;
              }

              // 전부 제출 상황일 떄(submission_status == submitted)
              final allItems = [...commuteList, ...singleList, ...remoteList, ...otherExpenseList];
              final isAllSubmitted = allItems.every((item) => item.submissionStatus == 'submitted');

              if (isAllSubmitted) {
                attentionDialog(context, '注意', '既に申請内訳を全て提出しました。');
                return;
              }

              // ✅ 신청 내역이 있을 때만 confirm 다이얼로그
              final confirmed = await ConfirmationDialog.show(
                context,
                message: '${currentMonth.year}年${currentMonth.month}月の申請内訳を提出しますか？\n提出したら、修正ができないです。',
              );

              if (!confirmed!) return;


              final finalSuccess = await fetchTransportationSubmit(
                'admins',
                currentMonth,
              );

              if (finalSuccess) {
                await successDialog(context, '一括提出完了', '${currentMonth.year}年${currentMonth.month}月の申請内訳を一括提出しました。');

                // ✅ Provider 강제 갱신
                ref.invalidate(transportationProvider(currentMonth));

                // Navigatorr.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) =>
                //         TransportationScreen(initialDate: currentMonth),
                //   ),
                //   (route) => false,
                // );
              } else {
                attentionDialog(context, 'エラー', '${currentMonth.year}年${currentMonth.month}月の申請内訳の一括提出を失敗しました。');
              }
            },
            saveText: '申　請',
            submitText: '一括提出',
            submitConfirmMessage: null,
            // submitConfirmMessage:
            //     '${currentMonth.year}年${currentMonth.month}月の申請内訳を提出しますか？\n提出したら、修正ができないです。',
            padding: 0,
            // 원하는 여백
            themeColor: const Color(0xFF0253B3), // 기본색 그대로 사용
          ),
        ),
      ),
    );
  }

  Widget getStatusIcon(String submissionStatus, String reviewStatus) {
    final icon = getStatusText(submissionStatus, reviewStatus);

    if (submissionStatus == 'draft') {
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
