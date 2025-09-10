// 연 그리드
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/styles.dart';

class YearGridSheet extends StatefulWidget {
  const YearGridSheet({
    super.key,
    required this.initialYear,
    required this.currentY,
    required this.currentM,
    required this.selectedY,
    required this.selectedM,
  });

  final int initialYear;
  final int currentY;
  final int currentM;
  final int selectedY;
  final int selectedM;

  @override
  State<YearGridSheet> createState() => _YearGridSheetState();
}

class _YearGridSheetState extends State<YearGridSheet> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final months = List<int>.generate(12, (i) => i + 1);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더: 연도, 이전/다음, 닫기
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: iosLabel,
                  onPressed: () => setState(() => _year--),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_year年',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: iosLabel),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: iosLabel,
                  onPressed: () => setState(() => _year++),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: iosSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 12개월 그리드
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9, // 월 pill 느낌
              children: months.map((m) {
                final isToday = (_year == widget.currentY && m == widget.currentM);
                final isSelected = (_year == widget.selectedY && m == widget.selectedM);

                final bg = isSelected ? iosBlue.withValues(alpha:0.12) : Colors.white;
                final border = isSelected ? iosBlue : (isToday ? iosSecondary : const Color(0xFFE5E5EA));
                final textColor = isSelected ? iosBlue :
                (isToday ? iosLabel : iosLabel);

                return Material(
                  color: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: border, width: 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop<({int year,int month})>(context, (year: _year, month: m));
                    },
                    child: Center(
                      child: Text(
                        '$m月',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
