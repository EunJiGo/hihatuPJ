import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../summary/formatters.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.summaryKey,
    required this.commuteCount,
    required this.commuteTotal,
    required this.singleCount,
    required this.singleTotal,
    required this.remoteCount,
    required this.remoteTotal,
    required this.othersCount,
    required this.othersTotal,
    required this.grandTotal,
  });

  final Key summaryKey;
  final int commuteCount, singleCount, remoteCount, othersCount;
  final int commuteTotal, singleTotal, remoteTotal, othersTotal, grandTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: summaryKey,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.8), blurRadius: 8, offset: const Offset(3, 4))],
      ),
      child: Column(
        children: [
          if (commuteCount > 0) ...[
            _row(icon: Icons.confirmation_number, color: const Color(0xFF81C784),
                label: '定期券($commuteCount件)', value: commuteTotal),
            const SizedBox(height: 10),
          ],
          if (singleCount > 0) ...[
            _row(icon: Icons.directions_bus, color: const Color(0xFFFFB74D),
                label: '交通費($singleCount件)', value: singleTotal),
            const SizedBox(height: 10),
          ],
          if (remoteCount > 0) ...[
            _row(icon: FontAwesomeIcons.houseLaptop, color: const Color(0xFFfeaaa9),
                label: '在宅勤務手当($remoteCount件)', value: remoteTotal),
            const SizedBox(height: 10),
          ],
          if (othersCount > 0) ...[
            _row(icon: Icons.receipt_long, color: const Color(0xFF89e6f4),
                label: '立替金($othersCount件)', value: othersTotal),
            const SizedBox(height: 10),
          ],
          const Divider(height: 1, thickness: 1, color: Colors.black54),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Color(0xFF37474F)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('総合計', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
              ),
              Text('￥${formatCurrency(grandTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF37474F))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({required IconData icon, required Color color, required String label, required int value}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black))),
        Text('￥${formatCurrency(value)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
