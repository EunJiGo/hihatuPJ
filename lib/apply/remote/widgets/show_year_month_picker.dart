import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showYearMonthPicker(BuildContext context, int year, int month) async {
  final now = DateTime.now();
  final List<int> years = List.generate(3, (i) => now.year - 1 + i);
  final List<int> months = List.generate(12, (i) => i + 1);

  int selectedYear = year;
  int selectedMonth = month;

  return await showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SizedBox(
            height: 300,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  '年月を選択してください。',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: years.indexOf(selectedYear),
                          ),
                          itemExtent: 36,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedYear = years[index];
                            });
                          },
                          children: years.map((y) => Center(child: Text('$y年'))).toList(),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMonth - 1,
                          ),
                          itemExtent: 36,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedMonth = months[index];
                            });
                          },
                          children: months.map((m) => Center(child: Text('$m月'))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(
                                color: Colors.red,
                            width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'キャンセル',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12), // 버튼 사이 간격
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            final selectedDate = DateTime(selectedYear, selectedMonth, 1);
                            Navigator.pop(context, selectedDate);
                          },
                          child: const Text(
                            '確認',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}
