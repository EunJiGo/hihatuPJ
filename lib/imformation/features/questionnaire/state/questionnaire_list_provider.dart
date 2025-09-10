import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire.dart';
import 'package:hihatu_project/imformation/features/questionnaire/data/fetch_questionnaire.dart';

// 질문 리스트 상태를 관리하는 StateNotifier
final questionnaireListProvider = StateNotifierProvider<QuestionnaireListNotifier, List<Questionnaire>>((ref) {
  return QuestionnaireListNotifier();
});

class QuestionnaireListNotifier extends StateNotifier<List<Questionnaire>> {
  QuestionnaireListNotifier() : super([]);

  Future<void> loadQuestionnaires() async {
    final result = await fetchQuestionnaireList();
    state = result.data; // fetchQuestionnaireList가 QuestionnaireResponse 타입 반환
  }
}
