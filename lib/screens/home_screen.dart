import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/logic/time_utils.dart';
import '../base/base_screen.dart';
import '../header/title_header.dart';
import '../utils/date/jp_formatted_home_date.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final day = DateTime(2025, 9, 2);   // 2025-09-02 23:00
    final time = DateTime(2025, 9, 2, 1, 30, 00);   // 2025-09-03 01:30
    
    final start = DateTime(2025, 9, 2, 9, 0);
    final end   = DateTime(2025, 9, 2, 11, 15);

// 두 시각의 차이(끝 - 시작) → Duration
    final diff = end.difference(start);      // 2시간 15분
    print(diff);
    print(diff.inMinutes);                   // 135

// DateTime에 Duration 더하기/빼기
    final plus = start.add(Duration(minutes: 30));   // 09:30
    final minus = end.subtract(Duration(hours: 1));  // 10:15
    
    print(plus);
    print(minus);

    return BaseScreen(
      child: Column(
        children: [
          WelcomeHeader(
            title: '高さん、お疲れ様です。\nHIHATUへようこそ！',
            subtitle: jpFormattedHomeDate(),
            titleFontSize: 18,
            subtitleFontSize: 12,
            imagePath: 'assets/images/home/home_image/home_image.png',
            imageWidth: 80,
          ),
        ],

      ),
    );
  }
}
