class OtherExpenseDetailItem {
  final DateTime createdAt; // 日付
  final String paymentRecipient; // 支払先
  final int totalFare; // 금액
  final String purpose; // 목적
  final String? imageUrl; // 첨부이미지에 대한 경로

  const OtherExpenseDetailItem({
    required this.createdAt,
    required this.paymentRecipient,
    required this.totalFare,
    required this.purpose,
    this.imageUrl,
  });
}