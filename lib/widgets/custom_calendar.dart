import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final Set<String> completedDays;
  final Function(DateTime selectedDay) onDayTapped;

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    required this.firstDay,
    required this.lastDay,
    required this.completedDays,
    required this.onDayTapped,
  });

  bool _isCompleted(DateTime day) {
    String key = DateFormat('yyyy-MM-dd').format(day);
    return completedDays.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: focusedDay,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: _isCompleted,
      onDaySelected: (selected, _) => onDayTapped(selected),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.white),
        weekendTextStyle: TextStyle(color: Colors.white70),
        outsideTextStyle: TextStyle(color: Colors.grey),
        todayDecoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.blue[100], fontWeight: FontWeight.bold),
        weekendStyle: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        formatButtonVisible: false,
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          final isMarked = _isCompleted(day);
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMarked ? Colors.black.withOpacity(0.8) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isMarked ? Colors.white : Colors.white70,
                fontWeight: isMarked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
