import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search workouts',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterMenu,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, _) {
                final workouts = _selectedFilter == 'All'
                    ? workoutProvider.workouts
                    : workoutProvider.workouts
                        .where((w) => w.type == _selectedFilter)
                        .toList();

                if (workouts.isEmpty) {
                  return const Center(
                    child: Text('No workouts found'),
                  );
                }

                return ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return _WorkoutListTile(workout: workout);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All'),
            onTap: () {
              setState(() => _selectedFilter = 'All');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Cardio'),
            onTap: () {
              setState(() => _selectedFilter = 'Cardio');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Strength'),
            onTap: () {
              setState(() => _selectedFilter = 'Strength');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Yoga'),
            onTap: () {
              setState(() => _selectedFilter = 'Yoga');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutListTile extends StatelessWidget {
  final Workout workout;

  const _WorkoutListTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        workout.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${workout.type} • ${workout.duration} min • ${workout.caloriesBurned} kcal',
      ),
      trailing: Text(
        DateFormat('MMM dd').format(workout.date),
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        // TODO: Show workout details
      },
    );
  }
}
