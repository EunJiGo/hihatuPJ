import 'package:flutter/material.dart';
import '../../apply_kind.dart';
import '../../others/other_expense_screen.dart';
import '../../remote/remoteScreen.dart';
import '../commuter/presentation/commuter_screen.dart';
import '../transportation/presentation/detail/transportation_detail_screen.dart';

typedef MonthUpdater = void Function(DateTime yyyymm);

class TransportationActions {
  TransportationActions({
    required this.context,
    required this.updateMonth,
    required this.afterInvalidate,
  });

  final BuildContext context;
  final MonthUpdater updateMonth;
  final VoidCallback afterInvalidate;

  Future<DateTime?> pushFor(ApplyKind kind) {
    final page = switch (kind) {
      ApplyKind.commute => const CommuterScreen(),
      ApplyKind.single  => const TransportationInputScreen(),
      ApplyKind.remote  => const RemoteScreen(),
      ApplyKind.other   => const OtherExpenseScreen(),
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
