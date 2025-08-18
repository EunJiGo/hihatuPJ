import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/commuter/commuter_screen.dart';
import 'package:hihatu_project/apply/transportations/sections/sections_view.dart';
import 'package:hihatu_project/apply/transportations/summary/transportation_actions.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/month_nav.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/submit_bar.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/summary_card.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/summary_toggle_mixin.dart';
import 'package:hihatu_project/apply/transportations/transportation/presentation/detail/transportation_detail_screen.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_approval_status.dart';
import 'package:hihatu_project/apply/transportations/transportation/state/transportation_view_model.dart';

import '../../tabbar/htt_tabbar.dart';
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
    // 데이터 로드/갱신 → 스크롤 불가면 합계 강제 표시
    ref.listen(transportationProvider(currentMonth), (_, next) {
      next.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ensureSummaryVisibleIfCantScroll();
        });
      });
    });

    final vm = ref.watch(transportationVMProvider(currentMonth));
    final ym = '${currentMonth.year}年 ${currentMonth.month}月';

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
    );

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            MonthNav(label: ym, onPrev: () => moveMonth(-1), onNext: () => moveMonth(1)),
            const SizedBox(height: 10),

            if (vm.hasAny) ...[
              Visibility(
                visible: isSummaryVisible,
                child: Column(children: [
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
                ]),
              ),
              const StatusExplanation(),
              const SizedBox(height: 10),

              SectionsView(
                vm: vm,
                scrollController: scrollController,
                flags: (commute: showCommuteList, single: showSingleList, remote: showRemote, other: showOtherExpenseList),
                onToggle: (key, value) => setState(() {
                  switch (key) {
                    case 'commute': showCommuteList = value; break;
                    case 'single':  showSingleList = value; break;
                    case 'remote':  showRemote = value; break;
                    case 'other':   showOtherExpenseList = value; break;
                  }
                }),
                onTapHandlers: (
                commute: (id) => actions.handleResult(Navigator.push<DateTime?>(
                  context, MaterialPageRoute(builder: (_) => const CommuterScreen()),
                )),
                single:  (id) => actions.handleResult(Navigator.push<DateTime?>(
                  context, MaterialPageRoute(builder: (_) => const TransportationInputScreen()),
                )),
                remote:  (id) => actions.handleResult(Navigator.push<DateTime?>(
                  context, MaterialPageRoute(builder: (_) => const RemoteScreen()),
                )),
                other:   (id) => actions.handleResult(Navigator.push<DateTime?>(
                  context, MaterialPageRoute(builder: (_) => const OtherExpenseScreen()),
                )),
                ),
                animation: animController,
                ensureSummaryVisibleIfCantScroll: ensureSummaryVisibleIfCantScroll,
              ),
            ] else
              const Expanded(child: Center(child: Text('申請履歴がないです。\n交通費及び定期券を申請してください。', textAlign: TextAlign.center))),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
          child: SubmitBar(
            vm: vm,
            currentMonth: currentMonth,
            actions: actions,
            invalidateProvider: (m) => ref.invalidate(transportationProvider(m)),
          ),
        ),
      ),
    );
  }
}