// 상단 헤더/메뉴 위젯이 들어있는 파일
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/widgets/year_calendar_page.dart'; // 연간 달력 페이지
import '../styles.dart';

// 선택 모드: 하루만 표시/선택할지(single), 이틀(pair)로 볼지
// list 목록형추가
enum SelectionMode { single, pair, list }

int modeToInt(SelectionMode m) {
  switch (m) {
    case SelectionMode.single: return 0;
    case SelectionMode.pair:   return 1;
    case SelectionMode.list:   return 2;
  }
}

SelectionMode intToMode(int v) {
  switch (v) {
    case 1: return SelectionMode.pair;
    case 2: return SelectionMode.list;
    default: return SelectionMode.single;
  }
}


// 헤더가 어떤 화면에서 쓰이는지 구분(월간/주간/연간/상세)
enum HeaderVariant { month, week, year, detail }

// 상단 헤더 위젯: StatelessWidget (내부 상태 없음, 모두 부모가 내려주는 값/콜백으로 동작)
class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({
    super.key, // Key 전달(옵션)
    required this.variant, // 현재 헤더 변형(월/주/연/상세)
    required this.isMonthView, // 현재 화면이 월간인지 여부
    required this.displayMonth, // 월간일 때 타이틀/표시에 사용할 기준 "달(1일로 정규화 가정)"
    required this.pivotDate, // 주간일 때 타이틀/표시에 사용할 기준 "날짜"
    required this.mode, // 선택 모드(single/pair)
    required this.onTapPrev, // 뒤로/이전 등 (월간에서는 사용 안 할 수도 있음)
    required this.onChangeMode, // 모드 바꾸기(single <-> pair)
    required this.onTapSearch, // 검색 버튼
    required this.onTapAdd, // 추가 버튼(+)
    required this.onSwitchToMonthFromWeek, // 주간 → 월간으로 스위치할 때
    required this.onTapThisMonth, // '今月'(이번 달) 버튼
    required this.onSelectMonthFromYear, // 연간 달력에서 월 선택했을 때 콜백
    this.onTapBackDetail, // (상세(detail) 전용) 뒤로가기
    this.onTapEdit, // (상세(detail) 전용) 편집
    this.hideWeekdayLabels = false,
  });

  // ======= 전달받는 프로퍼티들 =======
  final HeaderVariant variant; // 헤더 변형(월/주/연/상세)
  final bool isMonthView; // 현재 월간인지 여부
  final DateTime displayMonth; // 월간 기준 달(보통 1일 고정)
  final DateTime pivotDate; // 주간 기준일(타이틀/하이라이트)
  final SelectionMode mode; // single/pair

  // 콜백들 (부모가 구현해서 내려줌)
  final VoidCallback onTapPrev; // (하위 호환) 이전/뒤로
  final ValueChanged<SelectionMode> onChangeMode; // 모드 변경 시 전달
  final VoidCallback onTapSearch; // 검색 아이콘 탭
  final VoidCallback onTapAdd; // 추가 아이콘 탭
  final VoidCallback onSwitchToMonthFromWeek; // 주간 → 월간 스위치
  final VoidCallback onTapThisMonth; // '今月' 버튼
  final void Function(int year, int month)
  onSelectMonthFromYear; // 연간 → (year, month) 선택 전달

  // ===== 상세 화면에서만 쓰는 선택적 콜백 =====
  final VoidCallback? onTapBackDetail; // 뒤로가기 버튼
  final VoidCallback? onTapEdit; // 편집 버튼

  final bool hideWeekdayLabels;

  /// 상세 전용 헤더를 쉽게 만들기 위한 named constructor
  ScheduleHeader.detail({
    super.key,
    required DateTime monthForTitle, // 제목에 쓸 기준 날짜(보통 시작일)
    this.onTapBackDetail,
    this.onTapEdit,
    required this.hideWeekdayLabels,
  }) : variant = HeaderVariant.detail,
       // 변형을 detail로 고정
       isMonthView = true,
       // 상세에서도 좌측 타이틀 스타일을 월 기준으로 사용
       displayMonth = DateTime(monthForTitle.year, monthForTitle.month, 1),
       // 제목용 '해당 월 1일'
       pivotDate = monthForTitle,
       // 상세 타이틀에 날짜까지 표시하므로 pivot=그 날짜
       mode = SelectionMode.single,
       // 상세는 단일 날짜 컨텍스트
       onTapPrev = _noop,
       // 사용 안 하는 콜백은 noop으로 채움
       onChangeMode = _noopMode,
       onTapSearch = _noop,
       onTapAdd = _noop,
       onSwitchToMonthFromWeek = _noop,
       onTapThisMonth = _noop,
       onSelectMonthFromYear = _noopSelect;

  // 내부에서 쓰는 "아무 일도 안 하는" 콜백들(널 대신 안전하게 채우기)
  static void _noop() {}

  static void _noopMode(SelectionMode _) {}

  static void _noopSelect(int y, int m) {}

  // // ▼ 바텀시트 버전(주석 처리되어 있음): 연간 그리드를 모달로 띄우는 대체안
  //  Future<void> _openYearGrid(BuildContext context) async {
  //    final selected = await showModalBottomSheet<({int year, int month})>(
  //      context: context,
  //      useSafeArea: true,
  //      isScrollControlled: false,
  //      backgroundColor: Colors.white,
  //      builder: (_) =>
  //          YearGridSheet(
  //            initialYear: displayMonth.year,
  //            currentY: DateTime
  //                .now()
  //                .year,
  //            currentM: DateTime
  //                .now()
  //                .month,
  //            selectedY: displayMonth.year,
  //            selectedM: displayMonth.month,
  //          ),
  //    );
  //    if (selected != null) {
  //      onSelectMonthFromYear(selected.year, selected.month);
  //    }
  //  }

  // 연간 달력 페이지를 풀스크린에 가깝게 push해서 (year, month) 결과를 받는 메서드
  Future<void> _openYearCalendar(BuildContext context) async {
    // Navigator.push의 반환 타입을 Dart 3 레코드 타입 <({int year,int month})> 로 명시
    final result = await Navigator.of(context).push<({int year, int month})>(
      MaterialPageRoute(
        builder: (_) => YearCalendarPage(
          // 새로운 페이지로 이동
          year: displayMonth.year, // 연간 페이지가 처음 보여줄 '연도'
          currentY: DateTime.now().year, // 오늘의 연(현재 하이라이트용)
          currentM: DateTime.now().month, // 오늘의 월(현재 하이라이트용)
          selectedM: displayMonth.month, // 현재 선택된(보던) 월(초기 선택 표시용)
        ),
        fullscreenDialog: false, // iOS 스타일의 모달 프레젠테이션 여부(여기선 일반 push)
      ),
    );
    if (result != null) {
      // 연간에서 월을 골라 pop({year,month}) 해줬다면, 부모에게 선택 결과 전달
      onSelectMonthFromYear(result.year, result.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 타이틀 문자열 미리 구성
    final yearStr = '${displayMonth.year}年'; // 월간일 때 왼쪽 타이틀(연-년)
    final monthStrForWeekly = '${pivotDate.month}月'; // 주간일 때 왼쪽 타이틀(월-월)
    final listStr = '${pivotDate.year}年 ${pivotDate.month}月'; // 리스트 화면일 때 왼쪽 타이틀(년-월)
    final now = DateTime.now(); // 현재(오늘)
    final isCurrentMonth = // '今月' 버튼 활성/비활성 판단
        displayMonth.year == now.year && displayMonth.month == now.month;

    // === 연간 헤더 변형 ===
    if (variant == HeaderVariant.year) {
      return Container(
        color: Colors.white,
        child: SafeArea(
          // 노치/상단바 영역 피해서 그리기
          bottom: false, // 하단은 신경 안 씀
          child: Row(
            children: [
              const Spacer(), // 좌측 공간 비워 가운데/우측 정렬 보조
              IconButton(
                icon: const Icon(Icons.search_rounded),
                color: iosLabel,
                onPressed: onTapSearch,
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.add),
                color: iosBlue,
                onPressed: onTapAdd,
              ),
            ],
          ),
        ),
      );
    }

    // === ▼ 상세(Detail) 헤더 ===
    if (variant == HeaderVariant.detail) {
      // 원하는 레이아웃: "< 2025년 8월            편집"
      return Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                // 좌측 뒤로가기 버튼
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: iosLabel,
                  onPressed:
                      onTapBackDetail ?? () => Navigator.of(context).maybePop(),
                ),
                // 제목: pivotDate 기준 "M月 D日"
                // detail 분기
                Expanded(
                  child: Text(
                    '${pivotDate.month}月 ${pivotDate.day}日',
                    // 상세는 클릭한 날짜 기준으로 표기
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: iosLabel,
                    ),
                  ),
                ),
                // 우측 '편집' 버튼(콜백이 있을 때만 노출)
                if (onTapEdit != null)
                  TextButton(
                    onPressed: onTapEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: iosBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      '修正',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // === 월간/주간 공통 헤더 ===
    return Column(
      children: [
        // 상단 툴바 영역
        Container(
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 좌측 아이콘: (월간) → 연간 달력 열기 / (주간) → 전의 화면인 월간 뷰로 이동
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: iosLabel,
                onPressed: () => isMonthView
                    ? _openYearCalendar(context) // 월간이면 연간 페이지 열기
                    : onSwitchToMonthFromWeek(), // 주간이면 월간으로 되돌아가기
              ),
              // 좌측아이콘 옆 타이틀 위치: 월간이면 "YYYY年", 주간이면 "M月" 타이틀
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isMonthView ? yearStr : (mode == SelectionMode.list ? listStr : monthStrForWeekly),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: iosLabel,
                    ),
                  ),
                ),
              ),
              // 월간에서만 노출: '今月'(이번 달) 버튼
              if (isMonthView)
                TextButton(
                  onPressed: isCurrentMonth ? null : onTapThisMonth,
                  // 이미 이번 달이면 비활성화
                  style: TextButton.styleFrom(
                    foregroundColor: iosLabel,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    '今月',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              // 주간에서만 노출: 보기 모드 선택 팝업(single/pair)
              if (!isMonthView)
                PopupMenuButton<SelectionMode>(
                  // 제네릭으로 항목 타입 명시
                  color: Colors.white,
                  icon: const Icon(Icons.menu_rounded, color: iosLabel),
                  position: PopupMenuPosition.under,
                  // 아이콘 아래로 메뉴 표시
                  offset: const Offset(0, 8),
                  // 살짝 아래로 오프셋
                  onSelected: onChangeMode,
                  // 항목 선택 시 부모로 통지
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: SelectionMode.single, // 선택 값
                      checked: mode == SelectionMode.single, // 체크 상태
                      child: const Text('単一日'),
                    ),
                    CheckedPopupMenuItem(
                      value: SelectionMode.pair,
                      checked: mode == SelectionMode.pair,
                      child: const Text('複数日'),
                    ),
                    CheckedPopupMenuItem(
                      value: SelectionMode.list,
                      checked: mode == SelectionMode.list,
                      child: const Text('リスト'),
                    ),
                  ],
                ),
              // 우측: 검색/추가 버튼(월/주 공통)
              IconButton(
                icon: const Icon(Icons.search_rounded),
                color: iosLabel,
                onPressed: onTapSearch,
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.add),
                color: iosBlue,
                onPressed: onTapAdd,
              ),
            ],
          ),
        ),

        // 월간 화면에서만: 큰 월 타이틀(예: "8월")
        if (isMonthView)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              '${displayMonth.month}月',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: iosLabel,
              ),
            ),
          ),
        // 요일 헤더(일~토)
        // 주간 헤더이면서 hideWeekdayLabels=true 이면 감춤
        if (!(variant == HeaderVariant.week && hideWeekdayLabels))
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
            child: Row(
              children: List.generate(7, (i) {
                const labels = ['日', '月', '火', '水', '木', '金', '土'];
                final isSun = i == 0, isSat = i == 6; // 일/토 구분
                final c = isSun ? iosRed : (isSat ? iosBlue : iosSecondary);
                return Expanded(
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(color: c, fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
