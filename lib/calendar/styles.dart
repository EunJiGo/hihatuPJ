import 'package:flutter/material.dart';

const iosBlue = Color(0xFF007AFF);
const iosRed = Color(0xFFFF3B30);
const iosBg = Color(0xFFF2F2F7);
const iosLabel = Color(0xFF1C1C1E);
const iosSecondary = Color(0xFF8E8E93);

// 추가
const scheduleGreen = Color(0xFF34C759); // iOS System Green

// 주간/타임라인 뷰 레이아웃 스케일
const double railWidth = 56.0; // 왼쪽 시간표시 레일의 가로폭(px). 시간 라벨(8:00, 9:00…)과 눈금이 들어가는 영역 폭 → 이 값만큼 오른쪽에 실제 일정(EventBox) 칼럼이 시작됨
const double hourHeight = 80.0; // 1시간을 세로로 얼마나 높게 그릴지(px). 타임라인의 확대/축소 배율 같은 역할 → 30분이면 hourHeight * 0.5, 90분이면 hourHeight * 1.5 높이로 그려져.

const int minHour = 8; // 스케줄에 보여줄 처음 시각
const int maxHour = 19; // 스케줄에 보여줄 마지막 시각