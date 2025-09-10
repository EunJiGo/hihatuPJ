import 'package:flutter/material.dart';

import '../../detail/commuter/commuter_screen.dart';
import '../../detail/others/other_expense_screen.dart';
import '../../detail/remote/remote_screen.dart';
import '../../detail/single/single_screen.dart';
import '../../domain/enums/apply_kind.dart';

typedef MonthUpdater = void Function(DateTime yyyymm);

class TransportationActions {
  TransportationActions({
    required this.context,
    required this.updateMonth,
    required this.afterInvalidate,
    required this.getAnchorDate,
  });

  final BuildContext context;
  final MonthUpdater updateMonth;
  final VoidCallback afterInvalidate;
  final DateTime Function() getAnchorDate; // 👈 현재 위치의 날짜(월) 제공

  Future<DateTime?> pushFor(ApplyKind kind) {
    final anchor = getAnchorDate(); // ex) TransportationScreen의 currentMonth
    final page = switch (kind) {
      ApplyKind.commute =>  CommuterScreen(currentLocalDate: DateTime(anchor.year, anchor.month, anchor.day),),
      ApplyKind.single  =>  SingleScreen(currentLocalDate: DateTime(anchor.year, anchor.month, anchor.day),),
      ApplyKind.remote  =>  RemoteScreen(currentLocalDate: DateTime(anchor.year, anchor.month, anchor.day),),
      ApplyKind.other   => OtherExpenseScreen(currentLocalDate: DateTime(anchor.year, anchor.month, anchor.day),),
    };
    return Navigator.push<DateTime?>(
      context, MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> handleResult(Future<DateTime?> future) async {
    final res = await future;
    if (res == null) return;
    updateMonth(DateTime(res.year, res.month));
    afterInvalidate();
  }

}
