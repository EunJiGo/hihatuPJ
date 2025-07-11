import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransportationDetailScreen extends StatefulWidget {
  @override
  State<TransportationDetailScreen> createState() =>
      _TransportationDetailScreen();
}

class _TransportationDetailScreen extends State<TransportationDetailScreen> {
  DateTime currentDate = DateTime.now();

  void moveMonth(int diff) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + diff);
    });
  }
  @override
  Widget build(BuildContext context) {
    final ym = DateFormat('yyyy年 MM月').format(currentDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: '戻る',
        ),
        title: const Text(
          '交通費・定期券',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => setState(() => currentDate = DateTime.now()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
            ),

            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                  begin: Alignment.center,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minWidth: 64, minHeight: 36),
                  child: const Text(
                      '今月',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 1,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  )
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          // 현날짜 + 월 이동 버튼
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => moveMonth(-1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBDEFB),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                  child: const Text('先月'),
                ),
                Text(
                  ym,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => moveMonth(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBDEFB),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('次月'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
