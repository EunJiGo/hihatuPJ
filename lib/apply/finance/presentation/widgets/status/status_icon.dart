import 'dart:math' as math;
import 'package:flutter/material.dart';

Icon getStatusText(String submissionStatus, String reviewStatus) {
  if (submissionStatus == 'draft') {
    return const Icon(Icons.edit, color: Color(0xFF616161), size: 18); // 임시 저장
  }

  if (submissionStatus == 'submitted') {
    if (reviewStatus == 'pending') {
      return const Icon(
        Icons.hourglass_top,
        color: Color(0xFFeece01),
        size: 18,
      ); // 확인 중
    }
    if (reviewStatus == 'approved') {
      return const Icon(
        Icons.check_circle_outline,
        color: Color(0xFF33A1FD),
        size: 18,
      ); // 승인됨
    }
    if (reviewStatus == 'returned') {
      return const Icon(
        Icons.cancel_outlined,
        color: Color(0xFFE53935),
        size: 18,
      ); // 반려
    }
  }

  return const Icon(Icons.help_outline, color: Colors.grey, size: 18);
}

/// 애니메이션 포함 아이콘 반환
Widget buildStatusIcon({
  required String submissionStatus,
  required String reviewStatus,
  required Animation<double> animation, // 0~1 반복
}) {
  final icon = getStatusText(submissionStatus, reviewStatus);

  if (submissionStatus == 'draft') {
    // 좌우/대각 미세 흔들림
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final dx = math.sin(t * 2 * math.pi) * 2;
        return Transform.translate(offset: Offset(dx, dx), child: icon);
      },
    );
  }

  if (submissionStatus == 'submitted' && reviewStatus == 'pending') {
    return RotationTransition(turns: animation as Animation<double>, child: icon);
  }

  return icon;
}
