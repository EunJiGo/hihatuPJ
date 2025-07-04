import 'package:flutter/material.dart';
import 'package:hihatu_project/imformation/features/summary/presentation/questionnaire_status_legend.dart';

import '../../questionnaire/presentation/questionnaire_list_screen.dart';

class InformationTabs extends StatefulWidget {
  const InformationTabs({super.key});

  @override
  State<InformationTabs> createState() => _InformationTabsState();
}

class _InformationTabsState extends State<InformationTabs> {
  int selectedIndex = 0; // 0: お知らせ, 1: 安否確認

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 탭 버튼
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton('お知らせ', 0),
              _buildTabButton('安否確認', 1),
            ],
          ),
        ),
        // const SizedBox(height: 16),
        if (selectedIndex == 1) QuestionnaireStatusLegend(),

        const SizedBox(height: 16),

        // 선택된 리스트 보여주기
        if (selectedIndex == 0)
          _buildNoticeList()
        else
          Expanded(child: QuestionnaireListScreen())
          // _buildQuestionnaireList(),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
            fontSize: 16,
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

  Widget _buildQuestionnaireList() {
    return Column(
      children: const [
        Text('🛡️ 安否確認 리스트 1'),
        Text('🛡️ 安否確認 리스트 2'),
      ],
    );
  }
}
