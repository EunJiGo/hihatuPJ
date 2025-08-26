import 'package:flutter_riverpod/flutter_riverpod.dart';

/// null: 전체 보기
/// 0: 미작성
/// 1: 작성중
/// 2: 제출완료
/// 3: 제출기한지남
///
/// 중복가능

// final questionnaireFilterSetProvider = StateProvider<Set<int>>((ref) => <int>{});

final questionnaireFilterSetProvider =
StateProvider<Set<int>>((ref) => {0, 1, 2, 3}); // 모든 상태 ID