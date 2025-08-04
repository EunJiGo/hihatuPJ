import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showYearMonthPicker(BuildContext context) async {
  final now = DateTime.now();
  final List<int> years = List.generate(20, (i) => now.year - 10 + i);
  final List<int> months = List.generate(12, (i) => i + 1);

  int selectedYear = now.year;
  int selectedMonth = now.month;

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
                  '年月を選択してください',
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

                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final selectedDate = DateTime(selectedYear, selectedMonth, 1);
                            Navigator.pop(context, selectedDate);
                          },
                          child: const Text('確認'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
  );
}
