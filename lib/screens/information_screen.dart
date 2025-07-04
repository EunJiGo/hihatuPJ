import 'package:flutter/material.dart';
import 'package:hihatu_project/header/title_header.dart';
import '../base/base_screen.dart';
import '../imformation/features/questionnaire/presentation/questionnaire_list_screen.dart';
import '../imformation/features/summary/presentation/imformation_tap.dart';
import '../imformation/features/summary/presentation/unread_summary_widget.dart';

class InformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          WelcomeHeader(
            title: 'お知らせ',
            subtitle: 'お知らせ・安否確認をお願い致します。',
            titleFontSize: 20,
            subtitleFontSize: 14,
            imagePath: 'assets/images/technician/technician_image.png',
          ),
          SizedBox(
            height: 20,
          ),
          UnreadSummaryWidget(
            unreadNoticeCount: 1,
            unreadQuestionnaireCount: 3,
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: InformationTabs()),

          // Expanded(child: QuestionnaireListScreen()), // 중요!!
          //Column 안에 스크롤 가능한 위젯이 들어가면, Column은 무한 높이를 주려고 하기 때문에 QuestionnaireListScreen()의 높이가 무한대로 커지려고 해서 에러가 납니다.
          // 따라서 QuestionnaireListScreen()에 명확한 높이 제약을 주거나 Expanded로 감싸줘야 합니다.
        ],
      ),
    );
  }
}
