import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'apply_kind.dart';

class ApplyKindOption {
  static (IconData, Color) iconOf(ApplyKind k) => switch (k) {
    ApplyKind.commute => (Icons.confirmation_number, const Color(0xFF81C784)),
    ApplyKind.single  => (Icons.directions_bus, const Color(0xFFFFB74D)),
    ApplyKind.remote  => (FontAwesomeIcons.houseLaptop, const Color(0xFFfeaaa9)),
    ApplyKind.other   => (Icons.receipt_long, const Color(0xFF89e6f4)),
  };
}
