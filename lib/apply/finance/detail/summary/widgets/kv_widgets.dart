import 'package:flutter/material.dart';

Widget appCard({required Widget child}) => Card(
  color: Colors.white,
  elevation: 0.5,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(padding: const EdgeInsets.all(16), child: child),
);

Widget sectionTitle(String title) => Container(
  padding: const EdgeInsets.only(left: 8.0),
  alignment: Alignment.centerLeft,
  child: Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  ),
);

Widget labelValueRow(String label, String value, double? labelWidth) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SizedBox(
      width: labelWidth ?? 72,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(value == '' ? '-' : value)),
  ],
);
