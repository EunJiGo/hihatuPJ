import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/questionnaire_detail.dart';
import '../domain/questionnaire_detail_answer_response.dart';
import '../data/fetch_questionnaire_detail.dart';
import '../data/fetch_questionnaire_detail_answer.dart';
import '../data/fetch_save_questionnaire_answer.dart';

// 질문 상세와 답변 상태를 함께 관리하는 StateNotifier
class QuestionDetailState {
  final QuestionnaireDetail? detail;
  final QuestionnaireDetailAnswerResponse? answerResponse;
  final List<dynamic> selectedAnswers;
  final int answerStatus;
  final bool isLoading;
  final String? error;

  QuestionDetailState({
    this.detail,
    this.answerResponse,
    this.selectedAnswers = const [],
    this.answerStatus = 0,
    this.isLoading = false,
    this.error,
  });

  QuestionDetailState copyWith({
    QuestionnaireDetail? detail,
    QuestionnaireDetailAnswerResponse? answerResponse,
    List<dynamic>? selectedAnswers,
    int? answerStatus,
    bool? isLoading,
    String? error,
  }) {
    return QuestionDetailState(
      detail: detail ?? this.detail,
      answerResponse: answerResponse ?? this.answerResponse,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      answerStatus: answerStatus ?? this.answerStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class QuestionDetailNotifier extends StateNotifier<QuestionDetailState> {
  QuestionDetailNotifier(this.questionnaireId) : super(QuestionDetailState()) {
    loadData();
  }

  final int questionnaireId;

  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final detail = await fetchQuestionnaireDetail(questionnaireId);
      final answerResponse = await fetchQuestionnaireDetailAnswer(questionnaireId);

      // 답변 초기화 로직 (null 유지 등) 여기서 구현
      List<dynamic> selectedAnswers = List.generate(
        detail.data.questions.length,
            (i) {
          final type = detail.data.questions[i].type;
          final answers = answerResponse.data?.answers;
          if (answers != null && i < answers.length) {
            final ans = answers[i];
            if (type == 'check') {
              if (ans is List) {
                return List<String?>.from(ans.map((e) => e?.toString()));
              } else {
                return List<String?>.filled(detail.data.questions[i].options.length, null);
              }
            } else {
              return ans?.toString();
            }
          } else {
            return type == 'check'
                ? List<String?>.filled(detail.data.questions[i].options.length, null)
                : null;
          }
        },
      );

      state = state.copyWith(
        detail: detail.data,
        answerResponse: answerResponse,
        selectedAnswers: selectedAnswers,
        answerStatus: answerResponse.data?.status ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateAnswer(int index, dynamic value) {
    final updated = [...state.selectedAnswers];
    updated[index] = value;
    state = state.copyWith(selectedAnswers: updated);
  }

  Future<bool> saveOrSubmit(int status) async {
    final answers = state.selectedAnswers;

    bool hasAnyAnswer = answers.any((ans) {
      if (ans == null) return false;
      if (ans is String && ans.trim().isEmpty) return false;
      if (ans is List && ans.every((e) => e == null || e.toString().trim().isEmpty)) return false;
      return true;
    });

    if (!hasAnyAnswer) {
      return false;
    }

    bool success = await fetchSaveQuestionnaireAnswer(
      questionnaireId: questionnaireId,
      status: status,
      answers: answers,
    );

    if (success) {
      state = state.copyWith(answerStatus: status);
    }

    return success;
  }
}

final questionDetailProvider = StateNotifierProvider.family<QuestionDetailNotifier, QuestionDetailState, int>((ref, questionnaireId) {
  return QuestionDetailNotifier(questionnaireId);
});
