import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<DateTime?> showYearMonthPicker(
  BuildContext context,
  int year,
  int month,
) async {
  final now = DateTime.now();

  // 연도 범위(원하면 파라미터로 빼기)
  final List<int> years = List.generate(7, (i) => now.year - 3 + i);
  final List<int> months = List.generate(12, (i) => i + 1);

  int selectedYear = year;
  int selectedMonth = month;

  final theme = Theme.of(context);
  final blue = const Color(0xFF0253B3);
  final red = const Color(0xFFD32F2F);
  final isDark = theme.brightness == Brightness.dark;

  return showModalBottomSheet<DateTime>(
    context: context,
    // backgroundColor: theme.colorScheme.surface,
    backgroundColor: Colors.white.withValues(alpha:0.95), // ← 불투명 흰색이 아니라 살짝 투명
    isScrollControlled: false,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        top: false,
        child: SizedBox(
          height: 340,
          child: Column(
            children: [
              // ── Grab handle
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha:0.24)
                      : Colors.black.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),

              // ── Header
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16,
              //     vertical: 2,
              //   ),
              //   child: Row(
              //     children: [
              //       Text(
              //         '年月を選択',
              //         style: theme.textTheme.titleMedium?.copyWith(
              //           fontWeight: FontWeight.w700,
              //         ),
              //       ),
              //       const Spacer(),
              //       IconButton(
              //         visualDensity: VisualDensity.compact,
              //         onPressed: () => Navigator.pop(context),
              //         icon: const Icon(Icons.close),
              //       ),
              //     ],
              //   ),
              // ),
              // Divider(
              //   height: 1,
              //   thickness: 1,
              //   color: isDark
              //       ? Colors.white.withValues(alpha:0.08)
              //       : Colors.black.withValues(alpha:0.06),
              // ),

              // ── Labels for columns
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '年',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha:
                            0.7,
                          ),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '月',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha:
                            0.7,
                          ),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Pickers
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Year picker
                      Expanded(
                        child: _PickerColumn<int>(
                          items: years,
                          initialIndex: years
                              .indexOf(selectedYear)
                              .clamp(0, years.length - 1),
                          itemToText: (y) => '$y年',
                          onChanged: (y) {
                            HapticFeedback.selectionClick();
                            selectedYear = y;
                          },
                          isDark: isDark,
                        ),
                      ),
                      // Month picker
                      Expanded(
                        child: _PickerColumn<int>(
                          items: months,
                          initialIndex: (selectedMonth - 1).clamp(
                            0,
                            months.length - 1,
                          ),
                          itemToText: (m) => '$m月',
                          onChanged: (m) {
                            HapticFeedback.selectionClick();
                            selectedMonth = m;
                          },
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Button bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: red, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: red,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          final selectedDate = DateTime(
                            selectedYear,
                            selectedMonth,
                            1,
                          );
                          Navigator.pop(context, selectedDate);
                        },
                        child: const Text('確認'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 개별 피커 컬럼 위젯: 돋보기/선택 오버레이/텍스트 스타일 포함
class _PickerColumn<T> extends StatelessWidget {
  const _PickerColumn({
    required this.items,
    required this.initialIndex,
    required this.itemToText,
    required this.onChanged,
    required this.isDark,
  });

  final List<T> items;
  final int initialIndex;
  final String Function(T) itemToText;
  final ValueChanged<T> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final baseText = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return Stack(
      children: [
        CupertinoPicker(
          scrollController: FixedExtentScrollController(
            initialItem: initialIndex,
          ),
          itemExtent: 40,
          magnification: 1.08,
          useMagnifier: true,
          squeeze: 1.1,
          onSelectedItemChanged: (index) => onChanged(items[index]),
          selectionOverlay: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white : Color(0xFF0253B3)).withValues(alpha:
                    0.3,
                  ),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Color(0xFF0253B3)).withValues(alpha:
                    0.3,
                  ),
                  width: 1,
                ),
              ),
            ),
          ),
          children: items
              .map((e) => Center(child: Text(itemToText(e), style: baseText)))
              .toList(),
        ),
        // 좌우 가장자리에 살짝 그라데이션으로 페이드(시각적 깊이)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isDark ? Colors.black : Colors.white).withValues(alpha:0.0),
                    (isDark ? Colors.black : Colors.white).withValues(alpha:0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
