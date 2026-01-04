import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsFuture = Future.wait([
      context.read<WorkoutProvider>().getTotalCaloriesToday(),
      context.read<WorkoutProvider>().getWorkoutCountToday(),
    ]).then((values) {
      return {
        'calories': values[0],
        'workouts': values[1],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Hello!'),
            Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            FutureBuilder<Map<String, int>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data ?? {'calories': 0, 'workouts': 0};

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Today\'s Calories',
                        value: '${stats['calories']} kcal',
                        icon: Icons.fire_truck,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Workouts',
                        value: '${stats['workouts']}',
                        icon: Icons.fitness_center,
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddWorkoutScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Workout'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to workouts
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View Workouts'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Weekly Activity Chart Placeholder
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Weekly Activity Chart Placeholder'),
              ),
            ),
            const SizedBox(height: 24),
            // Recent Workouts
            const Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, _) {
                final recentWorkouts = workoutProvider.getLastThreeWorkouts();

                if (recentWorkouts.isEmpty) {
                  return const Center(
                    child: Text('No workouts yet'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentWorkouts.length,
                  itemBuilder: (context, index) {
                    final workout = recentWorkouts[index];
                    return ListTile(
                      title: Text(workout.title),
                      subtitle: Text(
                        '${workout.type} • ${workout.duration} min • ${workout.caloriesBurned} kcal',
                      ),
                      trailing: Text(
                        DateFormat('MMM dd').format(workout.date),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
