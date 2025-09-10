import 'package:flutter/material.dart';
import '../summary/units/formatters.dart';
import '../summary/widgets/kv_widgets.dart';
import '../summary/widgets/server_image_upload.dart';
import 'data/other_expense_detail_item.dart';

/// 메인 위젯
Widget otherExpenseBuildDetailBody(OtherExpenseDetailItem item) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    child: Column(
      children: [
        // 카드 1: 基本情報（開始日・目的）
        sectionTitle('🗂 基本情報'),
        appCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelValueRow('日付', fmtJpDate(item.createdAt), null),
              const SizedBox(height: 8),
              labelValueRow('目的', item.purpose, null),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 카드 2: 料金・支払先・領収書
        sectionTitle('💳 料金・領収書'),
        appCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelValueRow('料金', fmtYen(item.totalFare), null),
              const SizedBox(height: 8),
              labelValueRow('支払先', item.paymentRecipient, null),
              const SizedBox(height: 8),
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                Text(
                  '領収書(添付された写真を参考)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                ServerImageUpload(
                  focusNode: FocusNode(),
                  imagePath: item.imageUrl,
                  themeColor: const Color(0xFF0253B3),
                  shadowColor: const Color(0x2281C784),
                  isDisabled: true,
                  // 업로드 활성화 -- 이상
                  onImageSelected: (path) {},
                ),
              ],
              if (item.imageUrl == null || item.imageUrl!.isEmpty)
                labelValueRow('領収書', 'なし', null),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}
