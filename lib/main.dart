import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/tabbar/htt_tabbar.dart';

/*
1단계: Riverpod 도입 및 기본 상태관리 구조 만들기
앱 최상단에 ProviderScope 감싸기
main.dart에서 앱 전체를 ProviderScope로 감싸야 Riverpod 상태관리 사용 가능해집니다.
 */

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HHT App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HHTTabbar(),
    );
  }
}

