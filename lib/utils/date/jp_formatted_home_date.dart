String jpFormattedHomeDate() {
  final now = DateTime.now();

  // 요일 일본어 변환 맵
  const weekdayJapanese = {
    1: '月',
    2: '火',
    3: '水',
    4: '木',
    5: '金',
    6: '土',
    7: '日',
  };

  // 令和元년은 2019년 5월 1일 부터 시작
  final reiwaStart = DateTime(2019, 5, 1);

  int reiwaYear;
  if (now.isBefore(reiwaStart)) {
    // 2019년 4월 30일 이전 날짜면 令和가 아님 (다른 연호 처리 필요)
    reiwaYear = now.year - 1988; // 예: Heisei (平成) 계산 식 (임시)
  } else {
    reiwaYear = now.year - 2018; // 2019 -> 1년 (元年), 2025 -> 7년
  }

  // 1년은 元年으로 표기
  final reiwaYearStr = reiwaYear == 1 ? '元' : reiwaYear.toString();

  final formatted = '令和$reiwaYearStr年 ${now.year}年${now.month}月${now.day}日(${weekdayJapanese[now.weekday]})';

  return formatted;
}
