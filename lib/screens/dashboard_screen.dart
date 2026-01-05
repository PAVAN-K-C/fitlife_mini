import 'package:fitlife_mini/screens/weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';
import 'workouts_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;  // Add this callback

  const DashboardScreen({Key? key, this.onNavigate}) : super(key: key);

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
            Text(_getGreeting()),
            Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadStats());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          icon: Icons.local_fire_department,
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
                        ).then((_) => setState(() => _loadStats()));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Workout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Use callback to switch to Workouts tab
                        if (widget.onNavigate != null) {
                          widget.onNavigate!(1); // Navigate to index 1 (Workouts)
                        }
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('View Workouts'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly Activity Chart
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: WeeklyChart(),
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
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No workouts yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = recentWorkouts[index];
                      return Card(
                        child: ListTile(
                          title: Text(workout.title),
                          subtitle: Text(
                            '${workout.type} • ${workout.duration} min • ${workout.caloriesBurned} kcal',
                          ),
                          trailing: Text(
                            DateFormat('MMM dd').format(workout.date),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddWorkoutScreen(workoutToEdit: workout),
                              ),
                            ).then((_) => setState(() => _loadStats()));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
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
