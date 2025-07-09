import 'package:flutter/material.dart';
import 'package:hihatu_project/screens/apply_screen.dart';
import 'package:hihatu_project/screens/mypage_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/home_screen.dart';
import '../screens/information_screen.dart';

// import '../screens/attendance_screen.dart';
// import '../screens/it_case_screen.dart';
// import '../screens/technician_screen.dart';
// import '../screens/cost_screen.dart';
// import '../screens/mine_screen.dart';

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

  final List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    InformationScreen(),
    ApplyScreen(),
    MypageScreen(),


    // ITCaseScreen(),
    // TechnicianScreen(),
    // CostScreen(),
    // MineScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 초기화 시만 사용

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
    BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage('assets/images/tabbar/apply/apply.png'),
        size: 18,
      ),
      activeIcon: ImageIcon(
        AssetImage('assets/images/tabbar/apply/apply.png'),
        size: 18,
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

    // BottomNavigationBarItem(
    //   icon: ImageIcon(AssetImage('images/ITCaseSelect.png')),
    //   activeIcon: ImageIcon(AssetImage('images/ITCaseSelect.png')),
    //   label: 'IT案件',
    // ),
    // BottomNavigationBarItem(
    //   icon: ImageIcon(AssetImage('images/TechnicianUnselect.png')),
    //   activeIcon: ImageIcon(AssetImage('images/TechnicianSelect.png')),
    //   label: '技術者',
    // ),
    // BottomNavigationBarItem(
    //   icon: ImageIcon(AssetImage('images/CostSelect.png')),
    //   activeIcon: ImageIcon(AssetImage('images/CostSelect.png')),
    //   label: '経費精算',
    // ),
    // BottomNavigationBarItem(
    //   icon: ImageIcon(AssetImage('images/MineUnselect.png')),
    //   activeIcon: ImageIcon(AssetImage('images/MineSelect.png')),
    //   label: 'マイン',
    // ),
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
