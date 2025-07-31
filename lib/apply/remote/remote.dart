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
        statusBarBrightness: Brightness.light, // iOS
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
            height: kToolbarHeight, // 기본 AppBar의 높이를 나타내는 상수
            decoration: BoxDecoration(
              color: Color(0xFFfeaaa9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0), // 왼쪽 위는 직각
                topRight: Radius.circular(0), // 오른쪽 위는 직각
                bottomLeft: Radius.circular(20), // 왼쪽 아래만 둥글게
                bottomRight: Radius.circular(20), // 오른쪽 아래만 둥글게
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ✅ 가운데 제목
                const Text(
                  '在宅勤務手当',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                // ✅ 왼쪽 뒤로가기 버튼
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black, // 아이콘 색
                  ),
                ),
              ],
            ),
          ),

          // 본문
          const Expanded(child: Center(child: Text('본문'))),
        ],
      ),
    );
  }
}
