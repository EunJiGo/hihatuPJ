import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/policies/remote_allowanceRules.dart';

/// 공통 모델: 정기권/교통비 항목 통합
class RemoteAndOtherItem {
  final int id; // 항목 ID
  final bool isRemote;
  final int amount; // 금액
  final String? updatedAt; // 신청 날짜
  final String? goals; // 목적 (단발 교통비)
  final String submissionStatus; // 신청 상태 (draft, submitted 등)
  final String reviewStatus; // 승인 상태 (pending, approved 등)

  RemoteAndOtherItem({
    required this.id,
    required this.isRemote,
    required this.amount,
    required this.updatedAt,
    this.goals,
    required this.submissionStatus,
    required this.reviewStatus,
  });
}

/// 커스텀 가능한 교통비/정기권 히스토리 리스트
class RemoteAndOtherItemHistoryList extends StatelessWidget {
  final List<RemoteAndOtherItem> items;
  final void Function(int id) onTap;
  final Widget Function(String submissionStatus, String reviewStatus)
  getStatusIcon;

  // 🔹 스타일 전달받기
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Color amountColor;
  final Color separatorIconColor;
  final Color secondaryTextColor;

  const RemoteAndOtherItemHistoryList({
    super.key,
    required this.items,
    required this.onTap,
    required this.getStatusIcon,
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.amountColor,
    required this.separatorIconColor,
    this.secondaryTextColor = const Color(0xFF515151),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // 스크롤 안 되도록 (SingleChildScrollView 내에 있으므로)
      itemCount: items.length,
      // transportationAsync 리스트에서  expenseType이 타입이 "commute"인 것만 그 길이
      itemBuilder: (context, index) {
        final item = items[index];
        final dateText = _formatDate(item.updatedAt);

        return GestureDetector(
          onTap: () => onTap(item.id),
          child: Container(
            margin: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 재택/경비정보 + 금액
                Row(
                  children: [
                    // Icon(leadingIcon, color: leadingIconColor, size: 22),
                    // SizedBox(width: item.isRemote ? 15 : 8),
                    Text(
                      item.isRemote ? _getRemoteAllowanceLabel(item.amount) ?? '-' : item.goals ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        // Text(
                        //   '￥',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //     color: amountColor,
                        //   ),
                        // ),
                        Text(
                          _formatCurrency(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 3,),
                        Text(
                          '円',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0253B3),
                            // color: amountColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: item.isRemote ? 13 : 10),

                // 하단: 신청일/기간or목적/상태
                Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 16,
                      color: Color(0xFFfe673e),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '申請日：$dateText',
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                    const Spacer(),
                    getStatusIcon(item.submissionStatus, item.reviewStatus),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(int? amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount ?? 0);
  }

  String _formatDate(String? date) {
    if (date == null) return '-';
    final parsed = DateTime.tryParse(date);
    return parsed != null ? DateFormat('MM/dd').format(parsed) : '-';
  }

  String? _getRemoteAllowanceLabel(int amount) {
    final match = remoteAllowanceRules.firstWhere(
      (rule) => rule['amount'] == amount,
      orElse: () => {},
    );

    return match.isNotEmpty ? match['label'] as String : null;
  }
}
