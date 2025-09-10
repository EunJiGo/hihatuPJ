import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hihatu_project/base/base_main_screen.dart';
import 'package:hihatu_project/mypage/suggestion/widget/scrollable_text_field.dart';
import 'package:hihatu_project/mypage/suggestion/widget/suggestion_drop_down.dart';
import 'package:hihatu_project/utils/dialog/attention_dialog.dart';
import 'package:hihatu_project/utils/dialog/success_dialog.dart';

import '../../header/title_header.dart';
import '../../utils/dialog/confirmation_dialog.dart';
import '../../utils/dialog/warning_dialog.dart';
import 'data/fetch_suggestion_input.dart';
import 'domain/suggestion_category_options.dart';

class SuggestionInputScreen extends ConsumerStatefulWidget {

  const SuggestionInputScreen({super.key});

  @override
  _SuggestionInputScreenState createState() => _SuggestionInputScreenState();
}

class _SuggestionInputScreenState extends ConsumerState<SuggestionInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _contentScrollController = ScrollController();

  String _category = '改善事項';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 상태바 배경 투명
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
      ),
    );
  }

  void _dismissKeyboard() {
    // 현재 포커스 해제
    FocusManager.instance.primaryFocus?.unfocus();
    // iOS에서도 확실히 닫히도록 키보드 강제 숨김
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: BaseMainScreen(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFEFF2F4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 커스텀 AppBar
              Container(
                height: kToolbarHeight - 20, // 기본 AppBar의 높이를 나타내는 상수
                // decoration: BoxDecoration(color: Colors.amber),
                decoration: BoxDecoration(color: Color(0xFFffffff)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 뒤로 가기 버튼
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        color: Color(0xffadadad), // 아이콘 색
                      ),
                    ),
                    // 제출 버튼
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: Text(
                            '申請',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0253B3),
                          ),
                        ),
                        onPressed: () async {
                          _dismissKeyboard();

                          if (_contentController.text.trim().isEmpty) {
                            await attentionDialog(context, '注意', '提案内容が入力されていません。');
                            return;
                          }

                          final confirmed = await ConfirmationDialog.show(
                            context,
                            message: '提案を提出しますか？',
                          );
                          if (confirmed != true) return;

                          try {
                            final ok = await fetchSuggestionInput(_contentController.text.trim());
                            if (ok) {
                              await successDialog(context, '送信完了', '提案を受け付けました。ありがとうございます。');
                              if (mounted) Navigator.pop(context, true);
                            } else {
                              await warningDialog(context, 'エラー', '送信に失敗しました。しばらくしてからもう一度お試しください。');
                            }
                          } catch (e) {
                            await warningDialog(context, 'エラー', '通信に失敗しました。ネットワークをご確認ください。');
                          }
                        },

                      ),
                    ),
                  ],
                ),
              ),

              WelcomeHeader(
                title: '提案作成',
                subtitle: 'あなたの声がより良い職場をつくります。',
                titleFontSize: 18,
                subtitleFontSize: 12,
                imagePath:
                    'assets/images/mypage/suggest/suggest_image/suggest_image.png',
                imageWidth: 110,
              ),

              // 본문
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // // 카테고리
                      // const Text(
                      //   'カテゴリ',
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 8),
                      // SuggestionDropDown(
                      //   options: suggestionCategoryOptions,
                      //   selectedValue:  suggestionCategoryOptions.contains(_category)
                      //       ? _category
                      //       : 'その他',
                      //   answerStatus: 0,
                      //   onChanged: (val) {
                      //     setState(() {
                      //       _category = val!;
                      //
                      //     });// 선택된 값 처리
                      //   },
                      // // ),

                      const SizedBox(height: 20),

                      // 내용
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/add/content.png',
                            width: 15,
                            height: 15,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            '提案内容',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ScrollableTextField(
                        controller: _contentController,
                        scrollController: _contentScrollController,
                        hintText: '提案やご意見など、自由にご記入ください。',
                        onChanged: (val) {
                          setState(() {
                            _contentController.text = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
