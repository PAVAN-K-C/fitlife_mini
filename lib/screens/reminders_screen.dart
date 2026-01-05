import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/reminder.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late Future<List<Reminder>> _remindersFuture;
  final _databaseService = DatabaseService();
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _remindersFuture = _databaseService.getAllReminders();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final isAllowed = await _notificationService.isNotificationAllowed();
    if (!isAllowed && mounted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Notifications'),
        content: const Text('Please allow notifications to receive reminders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _notificationService.requestPermissions();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  void _refreshReminders() {
    setState(() {
      _remindersFuture = _databaseService.getAllReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet. Tap + to add.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final isPast = reminder.scheduledTime.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    isPast ? Icons.alarm_off : Icons.alarm,
                    color: isPast ? Colors.grey : (reminder.isActive ? Colors.green : Colors.orange),
                  ),
                  title: Text(reminder.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(reminder.scheduledTime)} at ${DateFormat('hh:mm a').format(reminder.scheduledTime)}',
                      ),
                      if (isPast)
                        const Text(
                          'Past reminder',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: reminder.isActive && !isPast,
                        onChanged: isPast ? null : (value) async {
                          final updated = Reminder(
                            id: reminder.id,
                            title: reminder.title,
                            description: reminder.description,
                            scheduledTime: reminder.scheduledTime,
                            isActive: value,
                            frequency: reminder.frequency,
                          );

                          await _databaseService.updateReminder(updated);

                          if (value) {
                            await _notificationService.scheduleReminder(
                              id: reminder.id.hashCode,
                              title: reminder.title,
                              body: reminder.description.isEmpty
                                  ? 'Reminder at ${DateFormat('hh:mm a').format(reminder.scheduledTime)}'
                                  : reminder.description,
                              scheduledTime: reminder.scheduledTime,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reminder activated')),
                              );
                            }
                          } else {
                            await _notificationService.cancelReminder(reminder.id.hashCode);
                          }

                          _refreshReminders();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _notificationService.cancelReminder(reminder.id.hashCode);
                          await _databaseService.deleteReminder(reminder.id);
                          _refreshReminders();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reminder deleted')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: DateTime.now().hour + 1, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                final scheduledDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                if (scheduledDateTime.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a future time')),
                  );
                  return;
                }

                final reminder = Reminder(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  scheduledTime: scheduledDateTime,
                  isActive: true,
                );

                await _databaseService.addReminder(reminder);
                await _notificationService.scheduleReminder(
                  id: reminder.id.hashCode,
                  title: reminder.title,
                  body: reminder.description.isEmpty
                      ? 'Reminder at ${DateFormat('hh:mm a').format(scheduledDateTime)}'
                      : reminder.description,
                  scheduledTime: scheduledDateTime,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  _refreshReminders();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder added successfully!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
