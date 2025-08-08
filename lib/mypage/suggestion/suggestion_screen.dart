import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/base/base_main_screen.dart';
import 'package:hihatu_project/mypage/suggestion/domain/suggestion_item.dart';
import 'package:hihatu_project/mypage/suggestion/suggestion_input_screen.dart';
import 'package:hihatu_project/mypage/suggestion/suggestion_detail_screen.dart';

import '../../header/title_header.dart';
import 'data/fetch_suggestion.dart';

class SuggestionListScreen extends ConsumerStatefulWidget {
  final int? transportationId;

  const SuggestionListScreen({this.transportationId, super.key});

  @override
  _SuggestionListScreenState createState() => _SuggestionListScreenState();
}

class _SuggestionListScreenState extends ConsumerState<SuggestionListScreen> {
  List<Map<String, dynamic>> suggestions = [];
  bool isLoading = true;
  bool hasError = false;

  static const categoryList = [
    '改善事項',
    '不便事項',
    '業務効率化',
    '職場内の問題',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    try {
      final List<SuggestionItem> apiData = await fetchSuggestion();
      suggestions = buildSuggestionDisplayList(apiData);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading suggestions: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  List<Map<String, dynamic>> buildSuggestionDisplayList(List<SuggestionItem> items) {
    return items.map((item) {
      final id = item.id;
      final message = item.message.trim();
      final foundCategory = item.page?.trim() ?? 'その他';
      // final foundCategory = categoryList.firstWhere(
      //       (cat) => message.contains(cat),
      //   orElse: () => 'その他',
      // );
      return {
        'id': id,
        'content': message,
        'category': foundCategory,
        'date': item.createdAt.split('T').first,
      };
    }).toList();
  }

  IconData getIconForCategory(String category) {
    switch (category.trim()) {
      case '改善事項':
        return Icons.auto_fix_high_outlined;
      case '不便事項':
        return Icons.report_problem_outlined;
      case '業務効率化':
        return Icons.trending_up_outlined;
      case '職場内の問題':
        return Icons.business_outlined;
      case 'その他':
      default:
        return Icons.more_horiz_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseMainScreen(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFEFF2F4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커스텀 AppBar
            Container(
              height: kToolbarHeight - 25,
              decoration: const BoxDecoration(color: Color(0xFFffffff)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      color: Color(0xffadadad),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SuggestionInputScreen()),
                        );

                        if (created == true) {
                          setState(() => isLoading = true); // 스피너 보여주기 선택
                          await loadSuggestions();          // ✅ 서버에서 최신 목록 다시 가져오기
                        }
                      },
                      icon: const Icon(Icons.add, size: 20),
                      color: Color(0xFF0253B3),
                    ),
                  ),
                ],
              ),
            ),

            WelcomeHeader(
              title: '目安箱',
              subtitle: 'あなたの声を大切に記録しています。',
              titleFontSize: 18,
              subtitleFontSize: 12,
              imagePath: 'assets/images/mypage/suggest/suggest_image/suggest_image.png',
            ),

            // 본문
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                  ? const Center(child: Text('読み込みに失敗しました。'))
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12), // ✅ 아이템 간 간격
                itemBuilder: (context, index) {
                  final item = suggestions[index];

                  return Material(
                    color: Colors.white,
                    elevation: 2, // ✅ 그림자 여기서만 (BoxShadow 제거)
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias, // 둥근 모서리로 클리핑
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        print('tapped id: ${item['id']}');
                        Navigator.push(context,  MaterialPageRoute(
                            // builder: (context) => SuggestionFormScreen(suggestionId: item['id']),
                            builder: (context) => SuggestionFormScreenEx(suggestionId: item['id']),
                        ));
                      },
                      child: Padding( // ✅ 내부 패딩만
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['content'] ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 15, color: Color(0xFF0253B3)),
                                const SizedBox(width: 4),
                                Text(
                                  item['date'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Row(
                            //       children: [
                            //         const Icon(Icons.forum_outlined, size: 15, color: Color(0xFF0253B3)),
                            //         const SizedBox(width: 4),
                            //         Text(
                            //           item['category'],
                            //           style: const TextStyle(
                            //             fontSize: 13,
                            //             color: Color(0xFF000000),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     Text(
                            //       '${item['date']}',
                            //       style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
