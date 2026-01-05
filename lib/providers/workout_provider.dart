import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Workout> _workouts = [];
  bool _isLoading = false;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;

  Future<void> loadAllWorkouts() async {
    _isLoading = true;
    // Don't call notifyListeners() here - it causes the build error

    try {
      _workouts = await _databaseService.getAllWorkouts();
      _isLoading = false;
      notifyListeners(); // Only notify after data is loaded
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkoutsByType(String type) async {
    _isLoading = true;

    try {
      _workouts = await _databaseService.getWorkoutsByType(type);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout(Workout workout) async {
    try {
      await _databaseService.addWorkout(workout);
      // Reload all workouts to ensure proper sorting
      await loadAllWorkouts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      await _databaseService.updateWorkout(workout);
      final index = _workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        _workouts[index] = workout;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _databaseService.deleteWorkout(id);
      _workouts.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getTotalCaloriesToday() async {
    return await _databaseService.getTotalCaloriesToday();
  }

  Future<int> getWorkoutCountToday() async {
    return await _databaseService.getWorkoutCountToday();
  }

  List<Workout> getLastThreeWorkouts() {
    if (_workouts.isEmpty) return [];
    return _workouts.take(3).toList();
  }
}
