import 'package:flutter/material.dart';

Future<void> successDialog(
    BuildContext context,
    String title,
    String message,
    ) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFFdddddd), // 연한 민트색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ 체크 아이콘
            const Icon(
                Icons.check_circle_rounded, // solid 체크 아이콘
                color: Color(0xFF00C48C),   // 선명한 민트
                size: 48,
              ),

            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006644),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                height: 1.4,
                fontFamily: 'Rounded M+ 1c', // 둥글둥글한 일본폰트 추천!
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C48C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
