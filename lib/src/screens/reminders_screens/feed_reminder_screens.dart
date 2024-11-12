import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/reminder_providers/reminder_providers.dart';
import 'package:pet_diary/src/services/other_services/notification_services.dart';

class FeedReminderScreen extends ConsumerStatefulWidget {
  const FeedReminderScreen({super.key});

  @override
  ConsumerState<FeedReminderScreen> createState() => _FeedReminderScreenState();
}

class _FeedReminderScreenState extends ConsumerState<FeedReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TimeOfDay> _selectedTimes = [
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
  ];
  final List<String> _selectedPetIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'F E E D  R E M I N D E R',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPetAvatarSelection(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildContainer([
                  const SizedBox(height: 20),
                  _buildFrequencyControl(),
                  const SizedBox(height: 10),
                  ..._buildTimeSelectors(),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ElevatedButton(
          onPressed: _saveReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'S A V E  R E M I N D E R',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _selectedTimes.length > 1
              ? () {
                  setState(() {
                    _selectedTimes.removeLast();
                  });
                }
              : null,
          icon: Icon(
            Icons.remove_circle,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Text(
          'Reminders: ${_selectedTimes.length}',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: _selectedTimes.length < 6
              ? () {
                  setState(() {
                    _selectedTimes.add(const TimeOfDay(hour: 12, minute: 0));
                  });
                }
              : null,
          icon: Icon(
            Icons.add_circle,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPetAvatarSelection() {
    final asyncPets = ref.watch(petsProvider);
    return asyncPets.when(
      data: (pets) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: Column(
            children: [
              Divider(color: Theme.of(context).colorScheme.secondary),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: pets.map((pet) {
                    final isSelected = _selectedPetIds.contains(pet.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected
                              ? _selectedPetIds.remove(pet.id)
                              : _selectedPetIds.add(pet.id);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(pet.avatarImage),
                              radius: 30,
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(e.toString())),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  List<Widget> _buildTimeSelectors() {
    return List.generate(
      _selectedTimes.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: GestureDetector(
          onTap: () async {
            final picked = await showStyledTimePicker(
              context: context,
              initialTime: _selectedTimes[index],
            );
            if (picked != null) {
              setState(() {
                _selectedTimes[index] = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Reminder ${index + 1} Time',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(15),
                child: Text('⏱️', style: TextStyle(fontSize: 24)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorDark),
              ),
            ),
            child: Text(
              _selectedTimes[index].format(context),
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveReminder() async {
    if (_selectedPetIds.isEmpty) {
      _showErrorDialog('Please select at least one pet for the reminder.');
      return;
    }

    final reminderTitle = _selectedPetIds
        .map((id) {
          final pet =
              ref.read(petsProvider).value?.firstWhere((p) => p.id == id);
          return pet?.name ?? '';
        })
        .where((name) => name.isNotEmpty)
        .join(', ');

    for (var time in _selectedTimes) {
      final scheduledDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      final reminder = ReminderModel(
        id: generateUniqueId(),
        name: 'Feed Reminder',
        petId: _selectedPetIds.join(', '),
        userId: FirebaseAuth.instance.currentUser!.uid,
        scheduledDate: scheduledDate,
        emoji: '🍲',
        description: 'It’s time to feed ${reminderTitle}.',
        eventId: generateUniqueId(),
        isActive: true,
        notificationId: scheduledDate.hashCode,
      );

      await ref.read(reminderServiceProvider).addReminder(reminder);

      await NotificationService().createNotification(
        id: reminder.notificationId,
        title: 'Reminder: Feed ${reminderTitle}',
        body: reminder.description,
        scheduledDate: scheduledDate,
      );
    }

    Navigator.of(context).pop();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }
}
