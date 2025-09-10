import 'package:hihatu_project/apply/finance/detail/commuter/utils/commuter_date_and_stations.dart';

class CommuterDetailItem {
  final DateTime createdAt;        // 開始日
  final String durationLabel;      // "1ヶ月" | "3ヶ月" | "6ヶ月"
  final String project;            // 案件名
  final List<String> stations;     // 출발 + 경유 + 도착
  final String transportMode;      // "電車" 등
  final int totalFare;
  final String? imageUrl;

  const CommuterDetailItem({
    required this.createdAt,
    required this.durationLabel,
    required this.project,
    required this.stations,
    required this.transportMode,
    required this.totalFare,
    this.imageUrl,
  });

  DateTime get startDate => createdAt;
  DateTime get endDate {
    final months = durationLabel.startsWith('1') ? 1
        : durationLabel.startsWith('3') ? 3
        : 6;
    return createdAt.endDateForMonths(months);
  }
}
