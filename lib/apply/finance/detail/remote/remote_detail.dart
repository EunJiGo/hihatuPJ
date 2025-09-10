import 'package:flutter/material.dart';
import '../summary/units/formatters.dart';
import '../summary/widgets/kv_widgets.dart';
import 'data/remote_detail_item.dart';

/// 메인 위젯
Widget remoteBuildDetailBody(RemoteDetailItem item) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    child: Column(
      children: [
        // 카드 1: 基本情報（日付・在宅勤務日数・手当）
        sectionTitle('💳 在宅勤務日数・手当'),
        appCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelValueRow('日付', fmtJpDate(item.createdAt), 85),
              const SizedBox(height: 8),
              labelValueRow('在宅勤務日数', item.ruleLabel, 85),
              const SizedBox(height: 8),
              labelValueRow('在宅勤務手当', fmtYen(item.ruleAmount), 85),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}
