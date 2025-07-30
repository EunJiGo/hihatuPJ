import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as ref;

import 'transportations/transportation_screen.dart';
import 'transportations/transportation/state/transportation_provider.dart';

// class ApplicationListScreen extends StatelessWidget {
class ApplicationListScreen extends ConsumerWidget {
  final List<Map<String, dynamic>> applyItems = [
    {'label': '休暇管理', 'icon': Icons.beach_access},
    {'label': '交通費・定期券', 'icon': Icons.train},
    {'label': '在宅勤務手当', 'icon': Icons.home},
    {'label': 'その他の経費申請', 'icon': Icons.receipt_long},
    {'label': '書類発行申請', 'icon': Icons.description},
  ];

  final List<Map<String, String>> appliedHistory = [
    {'title': '在宅勤務手当', 'status': '承認待ち', 'date': '2025-07-08'},
    {'title': '休暇管理', 'status': '承認済み', 'date': '2025-07-05'},
    {'title': '交通費申請', 'status': '差戻し', 'date': '2025-07-02'},
  ];

  @override
  // Widget build(BuildContext context) {
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // backgroundColor: const Color(0xFFF5F7FA),
      // appBar: AppBar(
      //   title: const Text('申請・承認'),
      //   backgroundColor: const Color(0xFF82B1FF),
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '申請メニュー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            ...applyItems.map((item) {
              String tag = 'ListTile-Hero-${item['label']}';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Hero(
                  tag: tag,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Icon(
                        item['icon'],
                        color: const Color(0xFF42A5F5),
                      ),
                    ),
                    title: Text(
                      item['label'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF888888),
                    ),
                    onTap: () async {
                      final label = item['label'];

                      if (label == '休暇管理') {
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => VacationScreen()));
                      } else if (label == '交通費・定期券') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TransportationScreen()));

                        // // 로딩 다이얼로그 표시
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: false,
                        //   builder: (_) => const Center(
                        //     child: CircularProgressIndicator(color: Color(0xFF42A5F5)),
                        //   ),
                        // );
                        // try {
                        //   // 데이터를 먼저 await로 미리 불러오기
                        //   final result = await ref.read(transportationProvider(DateTime.now()).future);
                        //
                        //   // 로딩 다이얼로그 닫기
                        //   if (context.mounted) Navigator.of(context).pop();
                        //
                        //   // 데이터 준비 후에 화면 전환
                        //   if (context.mounted) {
                        //     Navigator.of(context).push(
                        //       PageRouteBuilder(
                        //         pageBuilder: (_, __, ___) => const TransportationScreen(),
                        //         transitionDuration: Duration.zero, // 전환 시간 제거!
                        //         reverseTransitionDuration: Duration.zero,
                        //       ),
                        //     );
                        //
                        //   }
                        // } catch (e) {
                        //   // 에러 시 로딩 닫기
                        //   if (context.mounted) Navigator.of(context).pop();
                        //
                        //   // 에러 알림
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('データの読み込みに失敗しました')),
                        //   );
                        // }
                      } else if (label == '在宅勤務手当') {
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => RemoteWorkAllowanceScreen()));
                      } else if (label == 'その他の経費申請') {
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => OtherExpenseScreen()));
                      } else if (label == '書類発行申請') {
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentRequestScreen()));
                      }
                    },
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            const Text(
              '申請・承認状況',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            ...appliedHistory.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '申請日：${item['date']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item['status'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(item['status'] ?? ''),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case '承認済み':
        return Colors.green;
      case '承認待ち':
        return Colors.orange;
      case '差戻し':
        return Colors.redAccent;
      default:
        return Colors.black;
    }
  }
}
