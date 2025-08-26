class SingleDetailItem {
  final DateTime createdAt; // 日付
  final String vendor; // 支払先
  final String arrivalStation; // 도착
  final int totalFare; // 금액
  final String purpose; // 목적
  final String? imageUrl; // 첨부이미지에 대한 경로

  const SingleDetailItem({
    required this.createdAt,
    required this.departureStation,
    required this.arrivalStation,
    required this.isRoundTrip,
    required this.transportMode,
    required this.totalFare,
    required this.purpose,
    this.imageUrl,
  });
}