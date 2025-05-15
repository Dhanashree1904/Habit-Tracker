import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';
import '../db/database_helper.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _habitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final newHabit = Habit(
      name: _habitController.text.trim(),
      highestStreak: 0,
      createdAt: _selectedDate.toIso8601String(),
    );

    await DatabaseHelper.instance.insertHabit(newHabit);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Habit"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: AppPadding.screen,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _habitController,
                decoration: const InputDecoration(
                  labelText: "Habit Name",
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter a habit name" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined),
                  const SizedBox(width: 10),
                  Text(DateFormat.yMMMd().format(_selectedDate)),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Start Date"),
                  )
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Save Habit", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
