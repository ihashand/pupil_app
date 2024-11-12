import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_providers/reminder_providers.dart';
import 'package:pet_diary/src/services/other_services/notification_services.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  final String petId;

  const ReminderScreen({super.key, required this.petId});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  bool isCurrentReminders = true;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'R E M I N D E R S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          _buildReminderTabs(context),
          const SizedBox(height: 7),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final reminderStream = ref.watch(remindersStreamProvider);

                return reminderStream.when(
                  data: (reminders) {
                    final filteredReminders = reminders.where((reminder) {
                      final reminderDate = reminder.scheduledDate;
                      return isCurrentReminders
                          ? reminder.isActive && reminderDate.isAfter(now)
                          : !reminder.isActive || reminderDate.isBefore(now);
                    }).toList();

                    if (filteredReminders.isEmpty) {
                      return Center(
                        child: Text(isCurrentReminders
                            ? 'No active reminders'
                            : 'No reminder history'),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredReminders.length,
                      itemBuilder: (context, index) {
                        final reminder = filteredReminders[index];
                        return ReminderTile(
                          reminder: reminder,
                          onDelete: () => _deleteReminder(context, reminder.id),
                          onToggleActive: () =>
                              _toggleReminderStatus(context, reminder),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton(context, 'Current Reminders', true),
          _buildTabButton(context, 'Reminders History', false),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isCurrentReminders = isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteReminder(BuildContext context, String reminderId) async {
    await NotificationService().cancelNotification(reminderId.hashCode);
    await ref.read(reminderServiceProvider).deleteReminder(reminderId);
  }

  Future<void> _toggleReminderStatus(
      BuildContext context, ReminderModel reminder) async {
    reminder.isActive = !reminder.isActive;
    await ref.read(reminderServiceProvider).updateReminder(reminder);

    if (reminder.isActive) {
      // Re-activate the notification
      await NotificationService().createNotification(
        id: reminder.id.hashCode,
        title: 'Reminder: ${reminder.name}',
        body: 'It’s time for: ${reminder.name}',
        scheduledDate: reminder.scheduledDate,
      );
    } else {
      // Deactivate the notification
      await NotificationService().cancelNotification(reminder.id.hashCode);
    }
  }
}

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Text(
            reminder.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          reminder.name,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          dateFormat.format(reminder.scheduledDate),
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                reminder.isActive
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: reminder.isActive
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              onPressed: onToggleActive,
            ),
            IconButton(
              icon:
                  Icon(Icons.delete, color: Theme.of(context).primaryColorDark),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
