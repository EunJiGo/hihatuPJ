import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 공통 모델: 정기권/교통비 항목 통합
class TransportationUiItem {
  final int id; // 항목 ID
  final String fromStation; // 출발역
  final String toStation; // 도착역
  final int amount; // 금액
  final bool isCommuter; // 정기권 여부 (true면 commute)
  final bool twice; // 왕복 여부 (교통비용일 때 사용)
  final String? durationStartDate; // 신청 날짜
  final String? durationEndDate; // 종료 날짜
  final String? goals; // 목적 (단발 교통비)
  final String? commuteDuration; // 정기권 기간
  final String submissionStatus; // 신청 상태 (draft, submitted 등)
  final String reviewStatus; // 승인 상태 (pending, approved 등)

  TransportationUiItem({
    required this.id,
    required this.fromStation,
    required this.toStation,
    required this.amount,
    required this.isCommuter,
    required this.twice,
    required this.durationStartDate,
    this.durationEndDate,
    this.goals,
    this.commuteDuration,
    required this.submissionStatus,
    required this.reviewStatus,
  });
}

/// 커스텀 가능한 교통비/정기권 히스토리 리스트
class TransportationHistoryList extends StatelessWidget {
  final List<TransportationUiItem> items;
  final void Function(int id) onTap;
  final Widget Function(String submissionStatus, String reviewStatus) getStatusIcon;

  // 🔹 스타일 전달받기
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Color amountColor;
  final Color separatorIconColor;
  final Color secondaryTextColor;

  const TransportationHistoryList({
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
      //shrinkWrap: true를 주면 ListView가 자식 위젯 크기에 맞춰 높이를 최소로 잡아줌
      // 대신 성능은 약간 떨어질 수 있으니 리스트 아이템 수가 많지 않을 때 권장
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),  // 스크롤 안 되도록 (SingleChildScrollView 내에 있으므로)
      itemCount: items.length, // transportationAsync 리스트에서  expenseType이 타입이 "commute"인 것만 그 길이
      itemBuilder: (context, index) {
        final item = items[index];
        final startDateText = _formatDate(item.durationStartDate);
        String? endDateText = _formatDate(item.durationEndDate) ?? '';

        return GestureDetector(
          onTap: () => onTap(item.id),
          child: Container(
            // margin: const EdgeInsets.only(bottom: 12),
            margin: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
                // 상단: 역 정보 + 금액
                Row(
                  children: [
                    // Icon(leadingIcon, size: 16, color: leadingIconColor),
                    // Icon(Icons.confirmation_number_outlined, size: 16, color: Color(0xFF0253B3)),
                    const SizedBox(width: 5),
                    Text(
                      item.fromStation,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      item.isCommuter
                          ? Icons.remove_rounded
                          : item.twice
                          ? Icons.repeat
                          : Icons.arrow_right_alt,
                      size: 16,
                      color: item.twice ? const Color(0xFF0125f3) : separatorIconColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.toStation,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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

                const SizedBox(height: 10),

                // 하단: 신청일/기간or목적/상태
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Color(0xFF0253B3)),
                    // const Icon(Icons.date_range, size: 16, color: Color(0xFFfe673e)),
                    const SizedBox(width: 4),
                    Text(
                      item.durationEndDate==null ? '開始日：$startDateText' : '$startDateText~$endDateText',
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      item.isCommuter ? Icons.timelapse : Icons.info_outline,
                      size: 16,
                        color: Color(0xFF0253B3),
                      // color: item.isCommuter ? const Color(0xFFfa6a23) : const Color(0xFF5b0075),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.isCommuter
                          ? _formatCommuteDuration(item.commuteDuration)
                          : (item.goals ?? '-'),
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
    return parsed != null ? DateFormat('M/d').format(parsed) : '-';
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';

    final y = dt.year.toString().padLeft(4, '0'); // 4자리 연도
    final m = dt.month.toString(); // 0 패딩 제거
    final d = dt.day.toString();   // 0 패딩 제거

    return '$y年$m月$d日';
  }

  String _formatCommuteDuration(String? duration) {
    switch (duration) {
      case '1m':
        return '１ヶ月';
      case '3m':
        return '３ヶ月';
      case '6m':
        return '６ヶ月';
      default:
        return '-';
    }
  }
}
