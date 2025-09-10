import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/imformation/features/summary/presentation/questionnaire_status_legend.dart';
import '../../questionnaire/presentation/questionnaire_list_screen.dart';
import '../../questionnaire/state/information_tab_index_provider.dart';

class InformationTabs extends ConsumerStatefulWidget {
  final int initialTabIndex; // 0: お知らせ, 1: 安否確認
  const InformationTabs({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<InformationTabs> createState() => _InformationTabsState();
}

class _InformationTabsState extends ConsumerState<InformationTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // 첫 프레임 이후 provider 초기값 세팅 (initState 중 직접 변경 금지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(informationTabIndexProvider.notifier);
      if (notifier.state != widget.initialTabIndex) {
        notifier.state = widget.initialTabIndex;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ref.listen은 build 안에서 호출 (버전 제약)
    ref.listen<int>(informationTabIndexProvider, (prev, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    // 단일 소스: 화면/하이라이트 모두 provider 값을 기준으로
    final currentIndex = ref.watch(informationTabIndexProvider);

    return Column(
      children: [
        // 탭 버튼
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton('お知らせ', 0, isSelected: currentIndex == 0),
              _buildTabButton('安否確認', 1, isSelected: currentIndex == 1),
            ],
          ),
        ),

        if (currentIndex == 1) ...[
          const QuestionnaireStatusLegend(),
          const Expanded(child: QuestionnaireListScreen()),
        ],

        if (currentIndex == 0) _buildNoticeList(),
      ],
    );
  }

  Widget _buildTabButton(String title, int index, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        // 사용자 액션에서 provider만 변경
        ref.read(informationTabIndexProvider.notifier).state = index;
        // TabController 이동은 위 build의 ref.listen이 처리
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF0253B3) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF0253B3) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeList() {
    return Column(
      children: const [
        Text('📢 お知らせ 리스트 1'),
        Text('📢 お知らせ 리스트 2'),
      ],
    );
  }
}
