import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import 'package:uuid/uuid.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Workout? workoutToEdit;

  const AddWorkoutScreen({
    Key? key,
    this.workoutToEdit,
  }) : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _descriptionController;
  
  String _selectedType = 'Cardio';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    
    if (widget.workoutToEdit != null) {
      _titleController = TextEditingController(text: widget.workoutToEdit!.title);
      _durationController = TextEditingController(text: widget.workoutToEdit!.duration.toString());
      _caloriesController = TextEditingController(text: widget.workoutToEdit!.caloriesBurned.toString());
      _descriptionController = TextEditingController(text: widget.workoutToEdit!.description);
      _selectedType = widget.workoutToEdit!.type;
      _selectedDate = widget.workoutToEdit!.date;
    } else {
      _titleController = TextEditingController();
      _durationController = TextEditingController();
      _caloriesController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveWorkout() {
    if (_titleController.text.isEmpty || _durationController.text.isEmpty || _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final workout = Workout(
      id: widget.workoutToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text,
      type: _selectedType,
      duration: int.parse(_durationController.text),
      caloriesBurned: int.parse(_caloriesController.text),
      date: _selectedDate,
      description: _descriptionController.text,
    );

    final workoutProvider = context.read<WorkoutProvider>();
    
    if (widget.workoutToEdit != null) {
      workoutProvider.updateWorkout(workout);
    } else {
      workoutProvider.addWorkout(workout);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutToEdit != null ? 'Edit Workout' : 'Add Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Morning Run',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['Cardio', 'Strength', 'Yoga']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value ?? 'Cardio'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Duration (minutes)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '30',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Calories Burned', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '250',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about your workout',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Workout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
