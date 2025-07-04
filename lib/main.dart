import 'package:flutter/material.dart';
import 'package:hihatu_project/tabbar/htt_tabbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HHT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HHTTabbar(),
    );
  }
}
