import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apply/apply_list.dart';
import '../base/base_screen.dart';
import '../header/title_header.dart';
import '../utils/date_utils.dart';

class ApplyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          WelcomeHeader(
            title: '申請・承認',
            subtitle: '休暇や交通費などの各種申請は\nこちらから行えます。',
            titleFontSize: 18,
            subtitleFontSize: 12,
            imagePath: 'assets/images/home/home_image/home_image.png',
          ),
          SizedBox(height: 10,),
          Expanded(child: ApplicationListScreen()),
          // Expanded(child: TransportionDetailScreen()),
          // Expanded(child: SummaryTotalBox())
        ],
      ),
    );
  }
}
