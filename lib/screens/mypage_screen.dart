import 'package:flutter/material.dart';
import '../base/base_main_screen.dart';
import '../header/title_header.dart';
import '../mypage/suggestion/suggestion_screen.dart';
import '../mypage/widget/profile_card_widget.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 메뉴 아이템 정의
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': '目安箱',
        'icon': Icons.mail_outline,
        'onTap': () {
          // TODO: 문의 화면 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SuggestionListScreen()),
          );
        },
      },
      {
        'label': '資産管理',
        'icon': Icons.devices_other,
        'onTap': () {
          // TODO: 자산관리 화면 이동
        },
      },
    ];
    return BaseMainScreen(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFEFF2F4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 상단 헤더
            WelcomeHeader(
              title: '高さんのマイページ',
              subtitle: 'アカウント情報やご意見送信はこちらから',
              titleFontSize: 20,
              subtitleFontSize: 14,
              imagePath: 'assets/images/mypage/mypage_image/mypage_image.png',
              imageWidth: 80,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // 👤 프로필 카드
                    ProfileCard(),

                    // 🧾 메뉴 리스트
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'サポート・情報',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        ...menuItems.map((item) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFE3F2FD),
                                child: Icon(
                                  item['icon'],
                                  color: const Color(0xFF42A5F5),
                                ),
                              ),
                              title: Text(
                                item['label'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF888888),
                              ),
                              onTap: item['onTap'],
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                    // 🚪 로그아웃
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFEBEE),
                            child: Icon(Icons.logout, color: Colors.red),
                          ),
                          title: const Text(
                            'ログアウト',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFF888888),
                          ),
                          onTap: () {
                            // TODO: 로그아웃 처리
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
