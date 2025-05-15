// Keep your imports as-is
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/habit_model.dart';
import '../db/database_helper.dart';
import '../utils/constants.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final Set<String> _completedDays = {};
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 365));
    _lastDay = DateTime.now().add(const Duration(days: 365));
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await DatabaseHelper.instance.getHabitLogs(widget.habit.id!);
    setState(() {
      _completedDays.clear();
      for (var log in logs) {
        _completedDays.add(log);
      }
    });
  }

  Future<void> _toggleDay(DateTime day) async {
    String dayKey = DateFormat('yyyy-MM-dd').format(day);
    final db = DatabaseHelper.instance;

    if (_completedDays.contains(dayKey)) {
      await db.removeHabitLog(widget.habit.id!, dayKey);
      _completedDays.remove(dayKey);
    } else {
      await db.addHabitLog(widget.habit.id!, dayKey);
      _completedDays.add(dayKey);
    }

    await db.updateStreak(widget.habit.id!);

    setState(() {});
  }

  bool _isCompleted(DateTime day) {
    String key = DateFormat('yyyy-MM-dd').format(day);
    return _completedDays.contains(key);
  }

  Future<void> _confirmAndDeleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteHabit(widget.habit.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmAndDeleteHabit,
          ),
        ],
      ),
      body: Padding(
        padding: AppPadding.screen,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Tap days to mark as completed", style: AppTextStyles.hint),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: _isCompleted,
              onDaySelected: (selectedDay, focusedDay) {
                _focusedDay = focusedDay;
                _toggleDay(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isMarked = _isCompleted(day);
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isMarked ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isMarked ? Colors.white : Colors.black,
                        fontWeight: isMarked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FutureBuilder<int>(
                //   future: DatabaseHelper.instance.getCurrentStreak(widget.habit.id!),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData) return const CircularProgressIndicator();
                //     return Text(
                //       "⏳ Current Streak: ${snapshot.data} days",
                //       style: AppTextStyles.heading.copyWith(fontSize: 20),
                //     );
                //   },
                // ),
                const SizedBox(height: 10),
                FutureBuilder<int>(
                  future: DatabaseHelper.instance.getHighestStreak(widget.habit.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    return Text(
                      "🔥 Highest Streak: ${snapshot.data} days",
                      style: AppTextStyles.heading.copyWith(fontSize: 20),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
