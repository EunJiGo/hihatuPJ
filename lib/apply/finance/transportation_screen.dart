import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/commuter/commuter_screen.dart';
import 'package:hihatu_project/apply/finance/presentation/action/transportation_actions.dart';
import 'package:hihatu_project/apply/finance/presentation/sections/sections_view.dart';
import 'package:hihatu_project/apply/finance/presentation/summary/month_nav.dart';
import 'package:hihatu_project/apply/finance/presentation/summary/submit_bar.dart';
import 'package:hihatu_project/apply/finance/presentation/summary/summary_card.dart';
import 'package:hihatu_project/apply/finance/presentation/summary/transportation_approval_status.dart';
import 'package:hihatu_project/apply/finance/presentation/widgets/empty/no_history_message_widget.dart';
import 'package:hihatu_project/apply/finance/presentation/widgets/mixins/summary_toggle_mixin.dart';
import 'package:hihatu_project/apply/finance/state/transportation_provider.dart';
import 'package:hihatu_project/apply/finance/state/transportation_view_model.dart';
import '../../tabbar/htt_tabbar.dart';
import 'detail/others/other_expense_screen.dart';
import 'detail/remote/remote_screen.dart';
import 'detail/single/single_screen.dart';

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
    with SingleTickerProviderStateMixin, SummaryToggleMixin {
  DateTime currentMonth = DateTime.now();

  late final AnimationController animController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat();

  bool showCommuteList = true;
  bool showSingleList = true;
  bool showRemote = true;
  bool showOtherExpenseList = true;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.initialDate;
    initSummaryControllers();
  }

  @override
  void dispose() {
    animController.dispose();
    disposeSummaryControllers();
    super.dispose();
  }

  void moveMonth(int diff) {
    final newMonth = DateTime(currentMonth.year, currentMonth.month + diff);
    setState(() => currentMonth = newMonth);
    ref.invalidate(transportationProvider(newMonth));
    ensureSummaryVisibleIfCantScroll();
  }

  @override
  Widget build(BuildContext context) {
    // 1) 원본 비동기 상태를 본다
    final transAsync = ref.watch(transportationProvider(currentMonth));
    final ym = '${currentMonth.year}年 ${currentMonth.month}月';

    // 2) 데이터가 도착할 때 스크롤/요약 처리
    transAsync.whenData((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ensureSummaryVisibleIfCantScroll();
      });
    });

    final vmForBar = transAsync.maybeWhen(
      data: (_) => ref.watch(transportationVMProvider(currentMonth)),
      orElse: () => null,
    );

    // 컨트롤러 준비
    final actions = TransportationActions(
      context: context,
      updateMonth: (d) {
        setState(() => currentMonth = d);
        ref.invalidate(transportationProvider(currentMonth));
      },
      afterInvalidate: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ensureSummaryVisibleIfCantScroll();
        });
      },
      getAnchorDate: () => currentMonth,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // ↓ 스크롤 시 보라빛 오버레이를 없앰
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        // 상태바(아이콘 색 포함)도 고정
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
              onPressed: () {
                final now = DateTime.now();
                final thisMonth = DateTime(now.year, now.month);

                if (currentMonth.year != thisMonth.year ||
                    currentMonth.month != thisMonth.month) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            MonthNav(
              currentMonth: currentMonth,
              onPrev: () => moveMonth(-1),
              onNext: () => moveMonth(1),
              onSelectYearMonth: (picked) {
                setState(() => currentMonth = DateTime(picked.year, picked.month));
                ref.invalidate(transportationProvider(currentMonth));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) ensureSummaryVisibleIfCantScroll();
                });
              },
            ),
            const SizedBox(height: 10),

            // 3) 여기서 로딩/에러/데이터를 확실히 나눈다
            Expanded(
              child: transAsync.when(
                // --- 로딩 ---
                loading: () => const Center(child: CircularProgressIndicator()),
                // --- 에러 ---
                error: (e, st) =>
                    Center(child: Text('読み込みに失敗しました。${e.toString()}')),
                // --- 데이터 도착 ---
                data: (_) {
                  // 데이터가 있을 때만 뷰모델을 사용
                  final vm = ref.watch(transportationVMProvider(currentMonth));
                  if (!vm.hasAny) {
                    // 진짜로 데이터가 "없을 때"만 없음 화면을 보여준다
                    return NoHistoryMessage();
                    // return const Center(
                    //   child: Text(
                    //     '申請履歴がないです。\n交通費及び定期券を申請してください。',
                    //     textAlign: TextAlign.center,
                    //   ),
                    // );
                  }

                  // 데이터가 있을 때 리스트/요약 표시
                  return ListView(
                    children: [
                      Visibility(
                        visible: isSummaryVisible,
                        child: Column(
                          children: [
                            if (isSummaryVisible) ...[
                              SummaryCard(
                                summaryKey: summaryKey,
                                commuteCount: vm.commute.length,
                                commuteTotal: vm.commuteTotal,
                                singleCount: vm.single.length,
                                singleTotal: vm.singleTotal,
                                remoteCount: vm.remoteList.length,
                                remoteTotal: vm.remoteTotal,
                                othersCount: vm.others.length,
                                othersTotal: vm.othersTotal,
                                grandTotal: vm.grandTotal,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                      const StatusExplanation(),
                      SectionsView(
                        vm: vm,
                        flags: (
                          commute: showCommuteList,
                          single: showSingleList,
                          remote: showRemote,
                          other: showOtherExpenseList,
                        ),
                        onToggle: (key, value) => setState(() {
                          switch (key) {
                            case 'commute':
                              showCommuteList = value;
                              break;
                            case 'single':
                              showSingleList = value;
                              break;
                            case 'remote':
                              showRemote = value;
                              break;
                            case 'other':
                              showOtherExpenseList = value;
                              break;
                          }
                        }),
                        onTapHandlers: (
                          commute: (id) => actions.handleResult(
                            Navigator.push<DateTime?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommuterScreen(commuteId: id, currentLocalDate: currentMonth,),
                              ),
                            ),
                          ),
                          single: (id) => actions.handleResult(
                            Navigator.push<DateTime?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SingleScreen(singleId: id, currentLocalDate: currentMonth,),
                              ),
                            ),
                          ),
                          remote: (id) => actions.handleResult(
                            Navigator.push<DateTime?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RemoteScreen(remoteId: id, currentLocalDate: currentMonth,),
                              ),
                            ),
                          ),
                          other: (id) => actions.handleResult(
                            Navigator.push<DateTime?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OtherExpenseScreen(otherExpenseId: id, currentLocalDate: currentMonth,),
                              ),
                            ),
                          ),
                        ),
                        animation: animController,
                        ensureSummaryVisibleIfCantScroll:
                            ensureSummaryVisibleIfCantScroll,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: SubmitBar(
            vm: vmForBar, // nullable로 바꾸거나
            currentMonth: currentMonth,
            actions: actions,
            invalidateProvider: (m) =>
                ref.invalidate(transportationProvider(m)),
          ),
        ),
      ),
    );
  }
}
