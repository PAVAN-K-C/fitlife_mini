class Workout {
  final String id;
  final String title;
  final String type; // Cardio, Strength, Yoga
  final int duration; // in minutes
  final int caloriesBurned;
  final DateTime date;
  final String description;

  Workout({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    required this.date,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  static Workout fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      duration: map['duration'] as int,
      caloriesBurned: map['caloriesBurned'] as int,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String? ?? '',
    );
  }
}
