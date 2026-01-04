class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isActive;
  final String frequency; // daily, weekly, custom

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isActive = true,
    this.frequency = 'daily',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'frequency': frequency,
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      isActive: (map['isActive'] as int) == 1,
      frequency: map['frequency'] as String? ?? 'daily',
    );
  }
}
