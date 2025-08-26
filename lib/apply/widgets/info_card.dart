import 'package:flutter/material.dart';

class InfoRow {
  final String label;
  final String value;
  final IconData? icon;
  InfoRow(this.label, this.value, {this.icon});
}

class InfoCard extends StatelessWidget {
  final String? titleEmoji;
  final String? title;
  final List<InfoRow> rows;
  const InfoCard({super.key, this.titleEmoji, this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${titleEmoji ?? ''} ${title!}'.trim(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ...rows.map((r) => _row(r)).expand((w) => [w, const SizedBox(height: 8)]).toList()
              ..removeLast(), // 마지막 간격 제거
          ],
        ),
      ),
    );
  }

  Widget _row(InfoRow r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.icon != null) ...[
          Icon(r.icon, size: 18, color: const Color(0xFF0253B3)),
          const SizedBox(width: 6),
        ],
        SizedBox(
          width: 72,
          child: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(r.value)),
      ],
    );
  }
}
