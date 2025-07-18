import 'package:flutter/material.dart';
import 'package:hihatu_project/screens/apply_screen.dart';
import 'package:hihatu_project/screens/mypage_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/home_screen.dart';
import '../screens/information_screen.dart';


class HHTTabbar extends StatefulWidget {
  final int initialIndex;
  final int? informationTabIndex;

  const HHTTabbar({
    Key? key,
    this.initialIndex = 0,
    this.informationTabIndex,
  }) : super(key: key);

  @override
  State<HHTTabbar> createState() => _HHTTabbarState();
}

class _HHTTabbarState extends State<HHTTabbar> {
  int _selectedIndex = 0;

  late List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    InformationScreen(),
    ApplyScreen(),
    MypageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 초기화 시만 사용

    _screens = [
      HomeScreen(),
      AttendanceScreen(),
      InformationScreen(
        informationTabIndex: widget.informationTabIndex ?? 0,
      ),
      ApplyScreen(),
      MypageScreen(),
    ];

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

    });
  }

  final List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage('assets/images/tabbar/home/home_unselect.png'),
        size: 18,
      ),
      activeIcon: ImageIcon(
        AssetImage('assets/images/tabbar/home/home_select.png'),
        size: 18,
      ),
      label: 'ホーム',
    ),
    BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage('assets/images/tabbar/attendance/attendance_unselect.png'),
        size: 18,
      ),
      activeIcon: ImageIcon(
        AssetImage('assets/images/tabbar/attendance/attendance_select.png'),
        size: 18,
      ),
      label: '勤怠',
    ),
    BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage('assets/images/tabbar/attendance/attendance_unselect.png'),
        size: 18,
      ),
      activeIcon: ImageIcon(
        AssetImage('assets/images/tabbar/attendance/attendance_select.png'),
        size: 18,
      ),
      label: 'お知らせ',
    ),
    // BottomNavigationBarItem(
    //   icon: ImageIcon(
    //     AssetImage('assets/images/tabbar/apply/apply.png'),
    //     size: 18,
    //   ),
    //   activeIcon: ImageIcon(
    //     AssetImage('assets/images/tabbar/apply/apply.png'),
    //     size: 18,
    //   ),
    //   label: '申請',
    // ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/tabbar/apply/apply.png',
        width: 24,
        height: 24,
      ),
      activeIcon: Image.asset(
        'assets/images/tabbar/apply/apply.png',
        width: 24,
        height: 24,
      ),
      label: '申請',
    ),
    BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage('assets/images/tabbar/mypage/mypage_unselect.png'),
        size: 18,
      ),
      activeIcon: ImageIcon(
        AssetImage('assets/images/tabbar/mypage/mypage_select.png'),
        size: 18,
      ),
      label: 'マイページ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          // height: 70,
          // padding: const EdgeInsets.fromLTRB(30, 12, 30, 18),
          child: BottomNavigationBar(
            items: _items,
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF0253B3),
            unselectedItemColor: Color(0xFF333333),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11, // 고정 크기
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 11,
            ),
            backgroundColor: Colors.white,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
