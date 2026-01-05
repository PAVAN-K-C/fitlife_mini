import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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

  String? _titleError;
  String? _durationError;
  String? _caloriesError;

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

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _titleError = null;
      _durationError = null;
      _caloriesError = null;
    });

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Title is required');
      isValid = false;
    }

    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      setState(() => _durationError = 'Duration must be greater than 0');
      isValid = false;
    }

    final calories = int.tryParse(_caloriesController.text);
    if (calories == null || calories <= 0) {
      setState(() => _caloriesError = 'Calories must be greater than 0');
      isValid = false;
    }

    return isValid;
  }

  void _saveWorkout() {
    if (!_validateForm()) return;

    final workout = Workout(
      id: widget.workoutToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      type: _selectedType,
      duration: int.parse(_durationController.text),
      caloriesBurned: int.parse(_caloriesController.text),
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    final workoutProvider = context.read<WorkoutProvider>();
    if (widget.workoutToEdit != null) {
      workoutProvider.updateWorkout(workout);
    } else {
      workoutProvider.addWorkout(workout);
    }

    Navigator.pop(context);
  }

  void _deleteWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WorkoutProvider>().deleteWorkout(widget.workoutToEdit!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutToEdit != null ? 'Edit Workout' : 'New Workout'),
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
                errorText: _titleError,
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
                errorText: _durationError,
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
                errorText: _caloriesError,
              ),
            ),
            const SizedBox(height: 16),

            const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w500)),
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

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveWorkout,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Save'),
                    ),
                  ),
                ),
              ],
            ),

            if (widget.workoutToEdit != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _deleteWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete Workout'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
