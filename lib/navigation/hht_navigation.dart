import 'package:flutter/material.dart';

class HHTNavigation extends StatelessWidget {
  final Widget child;

  const HHTNavigation({
    required this.child,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }
}
