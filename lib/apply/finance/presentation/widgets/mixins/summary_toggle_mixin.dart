import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderBox;


mixin SummaryToggleMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController = ScrollController();
  bool isSummaryVisible = true;
  double _lastOffset = 0.0;
  double _dirAccum = 0.0;

  static const double toggleThreshold = 14.0;     // 토글 임계치
  static const double topStickyThreshold = 46.0;  // 맨 위 고정 임계치

  final GlobalKey summaryKey = GlobalKey();

  // ⬇️ 추가: 마지막으로 측정된 요약 높이 캐시
  double _lastMeasuredSummaryHeight = 0.0;

  double get summaryHeight {
    final box = summaryKey.currentContext?.findRenderObject() as RenderBox?;
    final h = box?.size.height ?? 0;
    if (h > 0) _lastMeasuredSummaryHeight = h; // 캐시 업데이트
    return h;
  }

  // double get summaryHeight {
  //   final box = summaryKey.currentContext?.findRenderObject() as RenderBox?;
  //   return box?.size.height ?? 0;
  // }

  void initSummaryControllers() {
    scrollController.addListener(_onScroll);
  }

  void disposeSummaryControllers() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
  }

  void ensureSummaryVisibleIfCantScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      final canScroll = scrollController.position.maxScrollExtent > 0;
      if (!canScroll && !isSummaryVisible) {
        setState(() {
          isSummaryVisible = true;
          _dirAccum = 0;
          _lastOffset = scrollController.position.pixels;
        });
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    final offset = pos.pixels;

    // 1) 콘텐츠가 화면보다 짧으면: 합계 항상 표시 + 상태 리셋
    if (pos.maxScrollExtent <= 0) {
      if (!isSummaryVisible) setState(() => isSummaryVisible = true);
      _lastOffset = offset;
      _dirAccum = 0;
      return;
    }

    // 2) 맨 위 근처에서는 항상 표시 + 상태 리셋
    if (offset < topStickyThreshold) {
      if (!isSummaryVisible) setState(() => isSummaryVisible = true);
      _lastOffset = offset;
      _dirAccum = 0;
      return;
    }

    // 3) 이동량 계산
    final delta = offset - _lastOffset;
    if (delta == 0) return;

    // 4) 같은 방향 누적, 방향 바뀌면 리셋
    if ((delta > 0 && _dirAccum >= 0) || (delta < 0 && _dirAccum <= 0)) {
      _dirAccum += delta;
    } else {
      _dirAccum = delta;
    }

    // 5) 숨기기 전 가드: 숨긴 뒤에도 스크롤이 남는지 정확히 예측
    const double remainMargin = 0.0;
    final double h = summaryHeight > 0 ? summaryHeight : _lastMeasuredSummaryHeight;

    // 뷰포트가 h 만큼 커지므로, 새로운 maxScrollExtent는 현재 - h
    final bool canPredict = h > 0;
    final bool willBeScrollableAfterHide = canPredict
        ? (pos.maxScrollExtent - h) > remainMargin
        : pos.maxScrollExtent > remainMargin; // 높이를 못 구하면 보수적으로 판단

    // 6) 임계치 넘을 때만 토글
    if (_dirAccum > toggleThreshold && isSummaryVisible) {
      if (willBeScrollableAfterHide) {
        setState(() => isSummaryVisible = false);
      }
      // 스크롤이 없어질 예측이면 숨기지 않음 (그대로 둠)
      _dirAccum = 0;
    } else if (_dirAccum < -toggleThreshold && !isSummaryVisible) {
      setState(() => isSummaryVisible = true);
      _dirAccum = 0;
    }

    _lastOffset = offset;
  }
}
