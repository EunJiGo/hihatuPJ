/// 하루/이틀/리스트 보기 모드
enum SelectionMode { single, pair, list }

/// 저장용 정수 변환 (기존 값 절대 변경 금지!)
int modeToInt(SelectionMode m) => switch (m) {
  SelectionMode.single => 0,
  SelectionMode.pair   => 1,
  SelectionMode.list   => 2,
};

SelectionMode intToMode(int v) => switch (v) {
  1 => SelectionMode.pair,
  2 => SelectionMode.list,
  _ => SelectionMode.single,
};

/// 헤더(타이틀바) 변형
enum HeaderVariant { month, week, year, detail }

/// 필터 타입
class MonthBadge {
  final int me;        // 自分
  final int people;    // 他の人
  final int equipment; // 設備
  const MonthBadge({this.me = 0, this.people = 0, this.equipment = 0});

  bool get isEmpty => me == 0 && people == 0 && equipment == 0;
}
