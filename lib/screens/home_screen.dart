import 'package:flutter/material.dart';
import '../base/base_screen.dart';
import '../header/title_header.dart';
import '../utils/date_utils.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: SafeArea(
        child: Column(
          children: [
            WelcomeHeader(
              title: '高さん、お疲れ様です。\nHIHATUへようこそ！',
              subtitle: getJapaneseFormattedDate(),
              titleFontSize: 18,
              subtitleFontSize: 12,
              imagePath: 'assets/images/home/home_image/home_image.png',
            ),
          ],
        ),
      ),
    );
  }
}
