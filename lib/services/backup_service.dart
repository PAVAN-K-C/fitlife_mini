import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/reminder.dart';
import '../models/workout.dart';
import '../services/database_service.dart';

class BackupService {
  final DatabaseService _databaseService = DatabaseService();

  Future<String> exportToJson() async {
    final workouts = await _databaseService.getAllWorkouts();
    final reminders = await _databaseService.getAllReminders();

    final Map<String, dynamic> exportData = {
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'workouts': workouts.map((w) => w.toMap()).toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
    };

    final jsonString = jsonEncode(exportData);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/fitlife_export.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  Future<bool> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Import workouts
      if (data.containsKey('workouts')) {
        final List<dynamic> workoutsData = data['workouts'];
        for (var workoutMap in workoutsData) {
          final workout = Workout.fromMap(workoutMap);
          await _databaseService.addWorkout(workout);
        }
      }

      // Import reminders
      if (data.containsKey('reminders')) {
        final List<dynamic> remindersData = data['reminders'];
        for (var reminderMap in remindersData) {
          final reminder = Reminder.fromMap(reminderMap);
          await _databaseService.addReminder(reminder);
        }
      }

      return true;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  Future<String?> getLastBackupPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/fitlife_export.json');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }
}
