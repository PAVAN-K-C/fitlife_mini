import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddWorkoutScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: 'Search workouts',
                      prefixIcon: const Icon(Icons.search),
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
                var workouts = workoutProvider.workouts;

                // Apply filter
                if (_selectedFilter != 'All') {
                  workouts = workouts
                      .where((w) => w.type == _selectedFilter)
                      .toList();
                }

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  workouts = workouts
                      .where((w) => w.title.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (workouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != 'All'
                              ? 'No workouts found'
                              : 'No workouts yet. Tap + to add.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
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
            trailing: _selectedFilter == 'All' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _selectedFilter = 'All');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Cardio'),
            trailing: _selectedFilter == 'Cardio' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _selectedFilter = 'Cardio');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Strength'),
            trailing: _selectedFilter == 'Strength' ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _selectedFilter = 'Strength');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Yoga'),
            trailing: _selectedFilter == 'Yoga' ? const Icon(Icons.check) : null,
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddWorkoutScreen(workoutToEdit: workout),
            ),
          );
        },
      ),
    );
  }
}
