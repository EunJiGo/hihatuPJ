import 'package:flutter/material.dart';
import 'package:hihatu_project/mypage/suggestion/suggestion_form_Screen.dart';

class SuggestionListScreen extends StatelessWidget {
  final List<Map<String, String>> suggestions = [
    {
      'title': '在宅勤務制度の改善提案',
      'date': '2025-08-01',
      'status': '承認待ち',
    },
    {
      'title': 'オフィスの空調改善要望',
      'date': '2025-07-25',
      'status': '承認済み',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目安箱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '申請する',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SuggestionFormScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '申請日：${item['date']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ステータス：${item['status']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _statusColor(item['status'] ?? ''),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
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
