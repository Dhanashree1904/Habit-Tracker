class Habit {
  final int? id;
  final String name;
  final int highestStreak;
  final String createdAt;

  Habit({
    this.id,
    required this.name,
    required this.highestStreak,
    required this.createdAt,
  });

  // Convert a Habit into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'highestStreak': highestStreak,
      'createdAt': createdAt,
    };
  }

  // Create a Habit from a Map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      highestStreak: map['highestStreak'],
      createdAt: map['createdAt'],
    );
  }
}
