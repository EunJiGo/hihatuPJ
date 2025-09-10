import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire_detail_response.dart';
import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire_detail_answer_response.dart';
import 'package:hihatu_project/imformation/features/questionnaire/data/fetch_questionnaire_detail.dart';
import 'package:hihatu_project/imformation/features/questionnaire/data/fetch_questionnaire_detail_answer.dart';

// 질문 상세 데이터 FutureProvider
final questionnaireDetailProvider = FutureProvider.family<QuestionnaireDetailResponse, int>((ref, questionnaireId) {
  return fetchQuestionnaireDetail(questionnaireId);
});

// 답변 데이터 FutureProvider
final questionnaireAnswerProvider = FutureProvider.family<QuestionnaireDetailAnswerResponse, int>((ref, questionnaireId) {
  return fetchQuestionnaireDetailAnswer(questionnaireId);
});

// 선택된 답변 상태를 저장하는 StateNotifier
class SelectedAnswersNotifier extends StateNotifier<List<dynamic>> {
  SelectedAnswersNotifier() : super([]);

  void setAnswers(List<dynamic> answers) {
    state = answers;
  }

  void updateAnswer(int index, dynamic value) {
    if (index < 0 || index >= state.length) return;
    final newList = [...state];
    newList[index] = value;
    state = newList;
  }
}

// 프로바이더 선언
final selectedAnswersProvider = StateNotifierProvider<SelectedAnswersNotifier, List<dynamic>>((ref) {
  return SelectedAnswersNotifier();
});

// 제출 상태 (0=보존, 1=제출)
final answerStatusProvider = StateProvider<int>((ref) => 0);
