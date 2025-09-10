import 'package:flutter/material.dart';
import '../apply/apply_list.dart';
import '../base/base_main_screen.dart';
import '../header/title_header.dart';

class ApplyScreen extends StatelessWidget {
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
              title: '申請・承認',
              subtitle: '休暇や交通費などの各種申請は\nこちらから行えます。',
              titleFontSize: 20,
              subtitleFontSize: 13,
              imagePath: 'assets/images/home/home_image/home_image.png',
              imageWidth: 80,
            ),
            Expanded(child: ApplicationListScreen()),
            // Expanded(child: TransportionDetailScreen()),
            // Expanded(child: SummaryTotalBox())
          ],
        ),
      ),
    );
  }
}
