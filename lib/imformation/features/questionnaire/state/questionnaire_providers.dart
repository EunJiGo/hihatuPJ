// providers/questionnaire_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../summary/utils/deadline.dart';
import '../state/questionnaire_list_provider.dart';
import '../domain/questionnaire.dart';

// 기한 안 지난 + 미작성/작성중
final actionableQuestionnaireCountProvider = Provider<int>((ref) {
  final list = ref.watch(questionnaireListProvider);
  return list.where((q) {
    final notExpired = !isExpiredEndOfDay(q.deadline);
    final notAnswered = q.answered != 1;
    return notExpired && notAnswered;
  }).length;
});

// 기한 안 지난 + 미작성
final notStartedCountProvider = Provider<int>((ref) {
  final list = ref.watch(questionnaireListProvider);
  return list.where((q) {
    final notExpired = !isExpiredEndOfDay(q.deadline);
    final notAnswered = q.answered != 1;
    final notSaved = q.saved != 1;
    return notExpired && notAnswered && notSaved;
  }).length;
});

// 기한 안 지난 + 작성중
final inProgressCountProvider = Provider<int>((ref) {
  final list = ref.watch(questionnaireListProvider);
  return list.where((q) {
    final notExpired = !isExpiredEndOfDay(q.deadline);
    final notAnswered = q.answered != 1;
    final saved = q.saved == 1;
    return notExpired && notAnswered && saved;
  }).length;
});
