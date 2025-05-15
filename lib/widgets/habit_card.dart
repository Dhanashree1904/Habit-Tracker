import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit_model.dart';
import '../utils/constants.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final createdDate = DateFormat.yMMMd().format(DateTime.parse(habit.createdAt));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.track_changes, size: 32, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Started on $createdDate",
                    style: AppTextStyles.hint,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text("🔥", style: TextStyle(fontSize: 24)),
                Text(
                  "${habit.highestStreak} days",
                  style: AppTextStyles.streak,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
