import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime selectedDay;
  final Color titleColor;
  final Color contentColor;

  const CalendarScreen({
    super.key,
    required this.selectedDay,
    required this.titleColor,
    required this.contentColor,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  bool useCustomCalendar = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    _focusedDay = _selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: widget.contentColor, // 아주 연한 베이지톤 배경
          appBar: AppBar(
            title: Text(
              '${_selectedDay.year}年 ${_selectedDay.month}月 ${_selectedDay.day}日',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: widget.titleColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCustomCalendar(),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCalendar() {
    return Column(
      children: [
        _customHeader(),
        const SizedBox(height: 10),
        _customWeekdayHeader(),
        const SizedBox(height: 12),
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          startingDayOfWeek: StartingDayOfWeek.sunday,
          headerVisible: false,
          daysOfWeekVisible: false,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              TextStyle textStyle = const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'ComicSansMS', // 귀여운 느낌의 폰트 (설치 필요하거나 기본 폰트 대체)
              );
              if (day.weekday == DateTime.sunday) {
                textStyle = textStyle.copyWith(color: Colors.redAccent);
              } else if (day.weekday == DateTime.saturday) {
                textStyle = textStyle.copyWith(color: Colors.blueAccent);
              }
              return Center(
                child: Text(
                  '${day.day}',
                  style: textStyle,
                ),
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB), // 부드러운 핑크
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'ComicSansMS',
                  ),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              TextStyle textStyle = const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'ComicSansMS', // 귀여운 느낌의 폰트 (설치 필요하거나 기본 폰트 대체)
              );
              if (day.weekday == DateTime.sunday) {
                textStyle = textStyle.copyWith(color: Colors.redAccent);
              } else if (day.weekday == DateTime.saturday) {
                textStyle = textStyle.copyWith(color: Colors.blueAccent);
              }
              return Center(
                child: Text(
                  '${day.day}',
                  style: textStyle,
                ),
              );
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            Navigator.pop(context, selectedDay);
          },
        ),
      ],
    );
  }

  Widget _customHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: 30,
          icon: const Icon(Icons.chevron_left, color: Color(0xFF4A90E2)),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            });
          },
        ),
        Text(
          '${_focusedDay.year}年${_focusedDay.month}月',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            // color: Color(0xFF7B1FA2), // 보라색 계열
            color: Colors.black,
            fontFamily: 'ComicSansMS',
          ),
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(Icons.chevron_right, color: Color(0xFF4A90E2)),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _customWeekdayHeader() {
    final japaneseWeekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return Row(
      children: List.generate(7, (index) {
        Color bgColor;
        Color textColor;
        if (index == 0) {
          bgColor = Colors.redAccent.withOpacity(0.15);
          textColor = Colors.redAccent;
        } else if (index == 6) {
          bgColor = Colors.blueAccent.withOpacity(0.15);
          textColor = Colors.blueAccent;
        } else {
          bgColor = Colors.grey.withOpacity(0.1);
          textColor = Colors.black87;
        }
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                japaneseWeekdays[index],
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}