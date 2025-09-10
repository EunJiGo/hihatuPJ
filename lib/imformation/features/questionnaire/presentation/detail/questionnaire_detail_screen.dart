import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/detail/widgets/question_submit_buttons.dart';
import '../../../../../apply/finance/api/fetch_image_upload.dart'; // 경로는 너 프로젝트에 맞춰
import '../../../../../utils/widgets/app_bar/basic_app_bar.dart';
import '../../../../../base/base_main_screen.dart';
import '../../../../../tabbar/htt_tabbar.dart';
import '../../../../../utils/date/date_utils.dart';
import '../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../utils/dialog/success_dialog.dart';
import '../../../../../utils/dialog/warning_dialog.dart';
import '../../../../../utils/widgets/app_bar/right_status_app_bar.dart';
import '../../data/fetch_questionnaire_detail.dart';
import '../../data/fetch_questionnaire_detail_answer.dart';
import '../../data/fetch_save_questionnaire_answer.dart';
import '../../domain/questionnaire_detail.dart';
import '../../domain/questionnaire_detail_answer_response.dart';
import '../../domain/questionnaire_detail_response.dart';
import '../../state/question_detail_provider.dart';
import 'widgets/question_item_widget.dart';
import 'widgets/question_image_upload.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final int questionnaireId;

  const QuestionDetailScreen({super.key, required this.questionnaireId});

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  List<TextEditingController> textControllers = [];
  final _uploadFocusNodes = <int, FocusNode>{}; // state에 보관 후 재사용
  bool isInitialized = false;
  bool _saving = false;

  // 로컬/서버 경로 판별
  bool _isLocalPath(String v) {
    final s = v.trim().toLowerCase();
    if (s.isEmpty) return false;
    if (s.startsWith('http://') || s.startsWith('https://')) return false;
    if (s.startsWith('uploads/')) return false; // 서버 상대경로
    if (s.startsWith('content://')) return true;
    if (s.startsWith('file://')) return true;
    if (s.startsWith('/')) return true;
    if (s.startsWith('ph://') || s.startsWith('assets-library://')) return true;
    return false; // abc.jpg 는 서버 파일명
  }

  void _goBackToInfoTab() {
    print("_goBackToInfoTab");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HHTTabbar(initialIndex: 2, informationTabIndex: 1),
      ),
          (route) => false,
    );
  }


  @override
  void initState() {
    super.initState();

    Future.wait([
      fetchQuestionnaireDetail(widget.questionnaireId),
      fetchQuestionnaireDetailAnswer(widget.questionnaireId),
    ]).then((results) {
      final detail = results[0] as QuestionnaireDetailResponse;
      final answerResponse = results[1] as QuestionnaireDetailAnswerResponse;

      final questions = detail.data.questions;
      final answers = answerResponse.data?.answers;

      final initialAnswers = List.generate(questions.length, (i) {
        final type = questions[i].type;
        if (answers != null && i < answers.length) {
          final ans = answers[i];
          if (type == 'check') {
            if (ans is List) {
              return List<String?>.from(ans.map((e) => e?.toString()));
            } else {
              return List<String?>.filled(questions[i].options.length, null);
            }
          } else {
            return ans?.toString();
          }
        } else {
          return type == 'check'
              ? List<String?>.filled(questions[i].options.length, null)
              : null;
        }
      });

      // 👇 provider 변경은 첫 프레임 이후
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedAnswersProvider.notifier).setAnswers(initialAnswers);
        ref.read(answerStatusProvider.notifier).state =
            answerResponse.data?.status ?? 0;

        textControllers = List.generate(questions.length, (i) {
          if (questions[i].type == 'text') {
            return TextEditingController(
              text: initialAnswers[i]?.toString() ?? '',
            );
          } else {
            return TextEditingController();
          }
        });

        if (mounted) setState(() => isInitialized = true);
      });
    });
  }

  Future<void> handleSaveOrSubmit(int status) async {
    // answers는 가공하므로 복사본으로 작업
    final answers = List.of(ref.read(selectedAnswersProvider));

    // 질문 메타 필요 (업로드 타입 여부 확인용)
    final detail =
    await ref.read(questionnaireDetailProvider(widget.questionnaireId).future);
    final questions = detail.data.questions;

    // 제출/저장 검증
    if (status == 1) {
      final hasEmpty = answers.asMap().entries.any((e) {
        final i = e.key;
        final ans = e.value;
        final t = questions[i].type;
        if (t == 'check') {
          if (ans is! List) return true;
          return ans.every((x) => x == null || x.toString().trim().isEmpty);
        } else {
          return ans == null || (ans is String && ans.trim().isEmpty);
        }
      });
      if (hasEmpty) {
        await attentionDialog(context, '注意', '入力していない項目があります。入力してください。');
        return;
      }
    } else {
      final anyFilled = answers.any((ans) {
        if (ans == null) return false;
        if (ans is String && ans.trim().isEmpty) return false;
        if (ans is List &&
            ans.every((e) => e == null || e.toString().trim().isEmpty)) {
          return false;
        }
        return true;
      });
      if (!anyFilled) {
        await attentionDialog(context, '注意', '何も入力されていません。');
        return;
      }
    }

    // ✅ 업로드 타입 정규화: 로컬 경로면 서버 업로드 → 서버 파일명/URL로 치환
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].type == 'upload') {
        final v = answers[i];
        if (v is String && v.isNotEmpty && _isLocalPath(v)) {
          final file = File(v.replaceFirst('file://', ''));
          if (file.existsSync()) {
            try{
              final uploaded = await fetchImageUpload('admins', file); // TODO: 실제 사용자 ID
              if (uploaded == null || uploaded.isEmpty) {
                await attentionDialog(context, 'アップロード失敗', '画像アップロードに失敗しました。');
                return;
              }
              answers[i] = uploaded; // 서버 파일명/URL로 교체
            } catch (_) {
              await attentionDialog(context, '通信エラー', 'ネットワークを確認してください。');
              return;
            }
          } else {
            await attentionDialog(context, '注意', '添付画像が見つかりません。再アップロードしてください。');
            return;
          }
        }
      }
    }

    // 서버 송신
    final success = await fetchSaveQuestionnaireAnswer(
      questionnaireId: widget.questionnaireId,
      status: status,
      answers: answers, // 정규화된 answers 사용
    );

    if (success) {
      await successDialog(
        context,
        '成功',
        status == 0 ? '保存が完了しました。' : '提出が完了しました。',
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const HHTTabbar(initialIndex: 2, informationTabIndex: 1),
        ),
            (route) => false,
      );
    } else {
      await warningDialog(context, 'エラー', '送信に失敗しました。');
    }
  }

  @override
  void dispose() {
    for (final n in _uploadFocusNodes.values) {
      n.dispose();
    }
    _uploadFocusNodes.clear();

    for (final c in textControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
    ref.watch(questionnaireDetailProvider(widget.questionnaireId));
    final answerStatus = ref.watch(answerStatusProvider);
    final selectedAnswers = ref.watch(selectedAnswersProvider);

    print('answerStatus: $answerStatus');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: BaseMainScreen(
        backgroundColor: Colors.white,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFEFF2F4),
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: _saving,
                child: Column(
                  children: [
                    // ✅ AppBar는 detailAsync의 상태에 따라 분기
                    detailAsync.when(
                      loading: () => BasicAppBar(onBack: _goBackToInfoTab),
                      error: (err, _) => BasicAppBar(onBack: _goBackToInfoTab),
                      data: (detail) {
                        final questionnaireDetail = detail.data;
                        final beforeDeadline =
                        isBeforeDeadline(questionnaireDetail.deadline);

                        // 상단에 보여줄 제목 결정
                        final String appBarTitle = (answerStatus == 1)
                            ? '提出完了'
                            : (!beforeDeadline ? '提出期間切れ' : questionnaireDetail.title);

                        // 제출완료 or 마감후 → TitleAppBar / 그 외 → BasicAppBar
                        if (answerStatus == 1 || !beforeDeadline) {
                          return RightStatusAppBar(title: appBarTitle, onBack: _goBackToInfoTab);
                        } else {
                          return BasicAppBar(onBack: _goBackToInfoTab);
                        }
                      },
                    ),

                    Container(color: Colors.white, height: 10),
                    Expanded(
                      child: detailAsync.when(
                        loading: () =>
                        const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('エラー: $err')),
                        data: (detail) {
                          if (!isInitialized) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final QuestionnaireDetail questionnaireDetail = detail.data;
                          final title = questionnaireDetail.title.trim();
                          final desc = questionnaireDetail.description.trim();
                          final hasHeader = title.isNotEmpty || desc.isNotEmpty;
                          final headerCount = hasHeader ? 1 : 0;
                          final beforeDeadline = isBeforeDeadline(questionnaireDetail.deadline);

                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: questionnaireDetail.questions.length +
                                      headerCount,
                                  itemBuilder: (context, index) {
                                    // 헤더(제목, 부가설명) 표시
                                    if (hasHeader && index == 0) {
                                      return Column(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(16),
                                                bottomRight: Radius.circular(16),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFFb7b7b7),
                                                  offset: Offset(4, 4),
                                                  blurRadius: 8,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                            // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                            padding: const EdgeInsets.only(bottom: 15, left: 16, right: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                if (title.isNotEmpty)...[
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.campaign_sharp,
                                                          size: 24,
                                                          color: Color(0xFFFFA726)),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        title,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF0253B3),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                // 본문 표시
                                                if (desc.isNotEmpty) ...[
                                                  const SizedBox(height: 5),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                    child: Text(
                                                      desc,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                          FontWeight.w600),
                                                    ),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10)
                                        ],
                                      );
                                    } else {
                                      final qIndex = hasHeader ? index - 1 : index;
                                      final q =
                                      questionnaireDetail.questions[qIndex];
                                      final ans = selectedAnswers.length > qIndex
                                          ? selectedAnswers[qIndex]
                                          : null;

                                      // // 🔸 업로드 문항: 선택 → 즉시 서버 업로드 → answers[qIndex]에 서버 파일명 저장
                                      // if (q.type == 'upload') {
                                      //   final focus = (_uploadFocusNodes[qIndex] ??= FocusNode());
                                      //   return Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 16, vertical: 8),
                                      //     child: QuestionImageUpload(
                                      //       focusNode: focus,
                                      //       answerStatus: answerStatus, // 1이면 read-only
                                      //       beforeDeadline: beforeDeadline,
                                      //       imagePath: ans as String?,
                                      //       onImageSelected: (localPath) {
                                      //         // ✅ 선택한 로컬 경로만 저장해 둔다 (업로드는 저장/제출에서 수행)
                                      //         ref
                                      //             .read(selectedAnswersProvider.notifier)
                                      //             .updateAnswer(qIndex, localPath);
                                      //       },
                                      //     ),
                                      //   );
                                      // }

                                      // 그 외 문항은 기존 위젯
                                      return QuestionItemWidget(
                                        question: q,
                                        answerStatus: answerStatus,
                                        beforeDeadline: beforeDeadline,
                                        answer: ans,
                                        textController:
                                        textControllers.length > qIndex
                                            ? textControllers[qIndex]
                                            : null,
                                        onChanged: (value) {
                                          ref
                                              .read(selectedAnswersProvider.notifier)
                                              .updateAnswer(qIndex, value);
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (answerStatus == 0 && beforeDeadline == true)
                                QuestionSubmitButtons(
                                  onSavePressed: _saving ? null : () async {
                                    setState(() => _saving = true);
                                    try {
                                      await handleSaveOrSubmit(0);
                                    } finally {
                                      if (mounted) setState(() => _saving = false);
                                    }
                                  },
                                  onSubmitPressed: _saving ? null : () async {
                                    setState(() => _saving = true);
                                    try {
                                      await handleSaveOrSubmit(1);
                                    } finally {
                                      if (mounted) setState(() => _saving = false);
                                    }
                                  },
                                )

                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_saving)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
