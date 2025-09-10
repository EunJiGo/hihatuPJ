import 'package:flutter/material.dart';
import 'package:hihatu_project/header/title_header.dart';
import '../base/base_main_screen.dart';
import '../imformation/features/summary/presentation/imformation_tap.dart';
import '../imformation/features/summary/presentation/unread_summary_widget.dart';

class InformationScreen extends StatelessWidget {
  final int? informationTabIndex;

  const InformationScreen({super.key, this.informationTabIndex}); // ← 추가

  @override
  Widget build(BuildContext context) {
    return BaseMainScreen(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFEFF2F4),
        child: Column(
          children: [
            WelcomeHeader(
              title: 'お知らせ',
              subtitle: 'お知らせ・安否確認をお願い致します。',
              titleFontSize: 20,
              subtitleFontSize: 14,
              imagePath: 'assets/images/technician/technician_image.png',
              imageWidth: 80,
            ),
            UnreadSummaryWidget(
              unreadNoticeCount: 1, // 임시
            ),
            Expanded(
              child: InformationTabs(initialTabIndex: informationTabIndex ?? 0),
            ),

            // Expanded(child: QuestionnaireListScreen()), // 중요!!
            //Column 안에 스크롤 가능한 위젯이 들어가면, Column은 무한 높이를 주려고 하기 때문에 QuestionnaireListScreen()의 높이가 무한대로 커지려고 해서 에러가 납니다.
            // 따라서 QuestionnaireListScreen()에 명확한 높이 제약을 주거나 Expanded로 감싸줘야 합니다.
          ],
        ),
      ),
    );
  }
}
