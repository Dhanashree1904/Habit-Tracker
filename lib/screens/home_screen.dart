import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'login_screen.dart';
import '../models/habit_model.dart';
import '../db/database_helper.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final db = DatabaseHelper.instance;
    List<Habit> habits = await db.getAllHabits();
    setState(() {
      _habits = habits;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _navigateToDetail(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(habit: habit),
      ),
    ).then((_) => _loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          )
        ],
      ),
      body: _habits.isEmpty
          ? const Center(child: Text("No habits yet. Add one!"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          return GestureDetector(
            onTap: () => _navigateToDetail(habit),
            child: HabitCard(habit: habit),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
          _loadHabits();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
