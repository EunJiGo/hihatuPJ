import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteScreen extends ConsumerStatefulWidget {
  const RemoteScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 상태바 배경 투명
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light,    // iOS
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // SafeArea로 상태바 높이 처리 + 흰 배경
          const SafeArea(
            bottom: false,
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(height: 0), // 그냥 상태바 영역만 확보
            ),
          ),

          // 커스텀 AppBar
          Container(
            height: kToolbarHeight,
            color: Colors.pink,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              '在宅勤務手当',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          // 본문
          const Expanded(
            child: Center(child: Text('본문')),
          ),
        ],
      ),
    );
  }
}
