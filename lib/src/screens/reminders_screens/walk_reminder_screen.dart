import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/reminder_models/walk_reminder_settings_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/reminder_providers/reminder_providers.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// A screen that displays walk reminders.
class WalkReminderScreen extends ConsumerStatefulWidget {
  const WalkReminderScreen({super.key});

  @override
  ConsumerState<WalkReminderScreen> createState() => _WalkReminderScreenState();
}

class _WalkReminderScreenState extends ConsumerState<WalkReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool globalIsActive = false;
  late Future<WalkReminderSettingsModel> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _initializeSettings();
  }

  Future<WalkReminderSettingsModel> _initializeSettings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final pets = await ref.read(petsProvider.future);
    final petIds = pets.map((pet) => pet.id).toList();

    if (userId != null) {
      var reminderSettings = await ref
          .read(walkReminderServiceProvider)
          .getWalkReminderSettings(userId);
      if (reminderSettings == null) {
        reminderSettings = WalkReminderSettingsModel(
          id: userId,
          userId: userId,
          globalIsActive: true,
          reminders: [
            ReminderSetting(
                time: const TimeOfDay(hour: 7, minute: 0),
                assignedPetIds: petIds,
                isActive: true),
            ReminderSetting(
                time: const TimeOfDay(hour: 13, minute: 0),
                assignedPetIds: petIds,
                isActive: true),
            ReminderSetting(
                time: const TimeOfDay(hour: 19, minute: 0),
                assignedPetIds: petIds,
                isActive: true),
          ],
        );
        await ref
            .read(walkReminderServiceProvider)
            .saveWalkReminderSettings(reminderSettings);
      }
      globalIsActive = reminderSettings.globalIsActive;
      return reminderSettings;
    }
    throw Exception("User not found");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'W A L K  R E M I N D E R',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        actions: [
          FutureBuilder<WalkReminderSettingsModel>(
            future: _settingsFuture,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(
                  Icons.save,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.85),
                  size: 30,
                ),
                onPressed: snapshot.connectionState == ConnectionState.done
                    ? () async {
                        if (snapshot.data != null) {
                          await _saveReminder(snapshot.data!);
                        }
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<WalkReminderSettingsModel>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final settings = snapshot.data!;
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildGlobalToggle(settings),
                  const SizedBox(height: 20),
                  if (globalIsActive) ..._buildReminderContainers(settings),
                  if (settings.reminders.length < 6)
                    if (globalIsActive) _buildAddReminderButton(settings),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddReminderButton(WalkReminderSettingsModel settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          if (settings.reminders.length < 6) {
            setState(() {
              settings.reminders.add(
                ReminderSetting(
                  time: const TimeOfDay(hour: 7, minute: 0),
                  assignedPetIds: settings.reminders.isNotEmpty
                      ? settings.reminders.first.assignedPetIds
                      : [],
                  isActive: true,
                ),
              );
            });
          }
        },
        icon: Icon(
          Icons.add,
          color: Theme.of(context).primaryColorDark,
        ),
        label: Text(
          'New Reminder',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  Widget _buildGlobalToggle(WalkReminderSettingsModel settings) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Activate All Reminders',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 100.0),
                  child: Switch(
                    activeColor: Theme.of(context).primaryColorDark,
                    value: globalIsActive,
                    onChanged: (value) {
                      setState(() {
                        globalIsActive = value;
                        settings.globalIsActive = value;
                        for (var reminder in settings.reminders) {
                          reminder.isActive = value;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReminderContainers(WalkReminderSettingsModel settings) {
    return settings.reminders.map((reminder) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: _buildTimePicker(reminder),
                  ),
                  _buildPetSelection(reminder),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
                onPressed: () {
                  setState(() {
                    settings.reminders.remove(reminder);
                  });
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTimePicker(ReminderSetting reminder) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showStyledTimePicker(
          context: context,
          initialTime: reminder.time,
        );
        if (pickedTime != null) {
          setState(() => reminder.time = pickedTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Time',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(reminder.time.format(context)),
      ),
    );
  }

  Widget _buildPetSelection(ReminderSetting reminder) {
    final asyncPets = ref.watch(petsProvider);
    return asyncPets.when(
      data: (pets) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: pets.map((pet) {
              final isSelected = reminder.assignedPetIds.contains(pet.id);
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? reminder.assignedPetIds.remove(pet.id)
                          : reminder.assignedPetIds.add(pet.id);
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(pet.avatarImage),
                    radius: 30,
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text(e.toString()),
    );
  }

  Future<void> _saveReminder(WalkReminderSettingsModel settings) async {
    // Cancel all walk notifications
    await _cancelWalkNotifications(settings.reminders);

    await ref
        .read(walkReminderServiceProvider)
        .saveWalkReminderSettings(settings);

    // Create new walk notifications
    final asyncPets = await ref.read(petsProvider.future);
    for (var reminder in settings.reminders) {
      if (reminder.isActive) {
        final petNames = asyncPets
            .where((pet) => reminder.assignedPetIds.contains(pet.id))
            .map((pet) => pet.name)
            .toList();
        final body = petNames.isNotEmpty
            ? 'Time to walk with: ${petNames.join(', ')}!'
            : 'Walking time!';

        await NotificationService().createDailyNotification(
          id: reminder.hashCode,
          title: 'Walk Reminder',
          body: body,
          time: reminder.time,
          payload: 'walk_reminder',
        );
        debugPrint(
            'Notification created: ID=${reminder.hashCode}, time=${reminder.time}, text=$body');
      }
    }

    // ignore: use_build_context_synchronously
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _cancelWalkNotifications(List<ReminderSetting> reminders) async {
    for (var reminder in reminders) {
      await NotificationService().cancelNotification(reminder.hashCode);
      debugPrint('Notification canceled: ID=${reminder.hashCode}');
    }
  }
}
