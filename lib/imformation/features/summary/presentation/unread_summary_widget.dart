import 'package:flutter/material.dart';

class UnreadSummaryWidget extends StatelessWidget {
  final int unreadNoticeCount;
  final int unreadQuestionnaireCount;

  const UnreadSummaryWidget({
    super.key,
    required this.unreadNoticeCount,
    required this.unreadQuestionnaireCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔔 타이틀
          Row(
            children: [
              Image.asset(
                'assets/images/add/notice_bell.png',
                height: 30,
                width: 25,
              ),
              const SizedBox(width: 6),
              const Text(
                '未確認状況',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // 📦 알림 요약 박스
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 📢 お知らせ
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    // color: const Color(0xFFE7F0FB), // 연한 파란색 배경
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        // 텍스트와 밑줄 사이 간격
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black54, // 밑줄 색상
                              width: 2, // 밑줄 두께
                            ),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.announcement_outlined,
                              size: 20,
                              color: Color(0xFF0253B3),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'お知らせ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${unreadNoticeCount}件',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🛡️ 安否確認
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    // color: const Color(0xFFE7F0FB), // 연한 파란색 배경
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        // 텍스트와 밑줄 사이 간격
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black54, // 밑줄 색상
                              width: 2, // 밑줄 두께
                            ),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.health_and_safety_outlined,
                              size: 20,
                              color: Color(0xFF0253B3),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '安否確認',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${unreadQuestionnaireCount}件',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
