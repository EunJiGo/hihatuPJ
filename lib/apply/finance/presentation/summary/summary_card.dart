import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../detail/commuter/utils/commute_formatters.dart';

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
            _row(icon: Icons.confirmation_number, iconColor: const Color(0xFF81C784), iconSize: 18, gap: 6,
                label: '定期券($commuteCount件)', value: commuteTotal),
            const SizedBox(height:3),
          ],
          if (singleCount > 0) ...[
            _row(icon: Icons.directions_bus, iconColor: const Color(0xFFFFB74D),iconSize: 18, gap: 6,
                label: '交通費($singleCount件)', value: singleTotal),
            const SizedBox(height:3)
          ],
          if (remoteCount > 0) ...[
            _row(icon: FontAwesomeIcons.houseLaptop, iconColor: const Color(0xFFfeaaa9),iconSize: 16, gap: 10,
                label: '在宅勤務手当($remoteCount件)', value: remoteTotal),
            const SizedBox(height:3)
          ],
          if (othersCount > 0) ...[
            _row(icon: Icons.receipt_long, iconColor: const Color(0xFF89e6f4),iconSize: 18, gap: 6,
                label: '立替金($othersCount件)', value: othersTotal),
            const SizedBox(height:3)
          ],
          const Divider(height: 1, thickness: 1, color: Colors.black26),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.black, size: 16),
              // const Icon(Icons.attach_money, color: Color(0xFF37474F), size: 16),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('総合計', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black)),
              ),
              Text('${formatCurrency(grandTotal)} 円',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({required IconData icon,  required Color iconColor, required double iconSize, required double gap, required String label, required int value}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize,),
        SizedBox(width: gap),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black))),
        Text('${formatCurrency(value)} 円',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
