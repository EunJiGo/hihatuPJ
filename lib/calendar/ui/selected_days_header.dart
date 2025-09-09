// 주간 상단 라벨
import 'package:flutter/material.dart';
import '../styles.dart';

class SelectedDaysHeader extends StatelessWidget {
  const SelectedDaysHeader({super.key, required this.days});
  final List<DateTime> days;

  String _jpShortW(DateTime d)
  => const ['日','月','火','水','木','金','土'][d.weekday % 7];

  @override
  Widget build(BuildContext context) {
    final isSingle = days.length <= 1;

    // ✅ days가 1개일 때: 화면 전체 기준 가운데 정렬 (railWidth 무시)
    if (isSingle) {
      final d = days.first;
      return Container(
        color: iosBg,
        height: 40,
        width: double.infinity,
        alignment: Alignment.center, // 전체 폭 기준 중앙
        child: Text(
          '${d.month}月${d.day}日（${_jpShortW(d)}）',
          style: const TextStyle(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // ✅ days가 2개 이상일 때: 기존 레이아웃 유지 (railWidth 만큼 띄우고, 영역 내 중앙)
    final colCount = days.length.clamp(1, 2);
    return Container(
      color: iosBg,
      height: 40,
      child: Row(
        children: [
          const SizedBox(width: railWidth), // 시간 레일 폭 확보
          Expanded(
            child: LayoutBuilder(
              builder: (context, cons) {
                final colWidth = cons.maxWidth / colCount;
                return Stack(
                  children: [
                    Row(
                      children: List.generate(colCount, (i) {
                        final d = days[i];
                        return SizedBox(
                          width: colWidth,
                          child: Center(
                            child: Text(
                              '${d.month}月${d.day}日（${_jpShortW(d)}）',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }),
                    ),
                    if (colCount == 2)
                      Positioned(
                        left: colWidth, top: 6, bottom: 6,
                        child: Container(
                          width: 1,
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
