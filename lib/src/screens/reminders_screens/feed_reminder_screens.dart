import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/reminder_models/feed_reminder_settings_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/reminder_providers/reminder_providers.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// FeedReminderScreen - ekran umożliwiający użytkownikowi ustawienie powiadomień
/// dotyczących karmienia zwierząt. Każde przypomnienie można włączyć/wyłączyć
/// oraz ustawić dla wybranych godzin i przypisanych zwierząt.

class FeedReminderScreen extends ConsumerStatefulWidget {
  const FeedReminderScreen({super.key});

  @override
  ConsumerState<FeedReminderScreen> createState() => _FeedReminderScreenState();
}

class _FeedReminderScreenState extends ConsumerState<FeedReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool globalIsActive = false;
  late Future<FeedReminderSettingsModel> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _initializeSettings();
  }

  /// Metoda inicjalizująca ustawienia przypomnień.
  /// Jeśli użytkownik nie ma zapisanych ustawień, tworzy domyślne z 3 godzinami.
  Future<FeedReminderSettingsModel> _initializeSettings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final pets = await ref.read(petsProvider.future);
    final petIds = pets.map((pet) => pet.id).toList();

    if (userId != null) {
      var reminderSettings = await ref
          .read(reminderServiceProvider)
          .getFeedReminderSettings(userId);
      if (reminderSettings == null) {
        reminderSettings = FeedReminderSettingsModel(
          id: userId,
          userId: userId,
          globalIsActive: false,
          reminders: [
            ReminderSetting(
                time: const TimeOfDay(hour: 8, minute: 0),
                assignedPetIds: petIds,
                isActive: false),
            ReminderSetting(
                time: const TimeOfDay(hour: 12, minute: 0),
                assignedPetIds: petIds,
                isActive: false),
            ReminderSetting(
                time: const TimeOfDay(hour: 18, minute: 0),
                assignedPetIds: petIds,
                isActive: false),
          ],
        );
        await ref
            .read(reminderServiceProvider)
            .saveFeedReminderSettings(reminderSettings);
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
      body: FutureBuilder<FeedReminderSettingsModel>(
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
                  const Divider(color: Colors.grey),
                  _buildGlobalToggle(settings),
                  const SizedBox(height: 20),
                  if (globalIsActive) ..._buildReminderContainers(settings),
                  if (settings.reminders.length < 6)
                    _buildAddReminderButton(settings),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ElevatedButton(
          onPressed: () async {
            final settings = await _settingsFuture;
            await _saveReminder(settings);
          },
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

  /// Przycisk dodania nowego przypomnienia.
  Widget _buildAddReminderButton(FeedReminderSettingsModel settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          if (settings.reminders.length < 6) {
            setState(() {
              settings.reminders.add(
                ReminderSetting(
                  time: const TimeOfDay(hour: 8, minute: 0),
                  assignedPetIds: settings.reminders.isNotEmpty
                      ? settings.reminders.first.assignedPetIds
                      : [],
                  isActive: false,
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
          'Add New Reminder',
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

  /// Globalny przełącznik aktywacji/deaktywacji wszystkich przypomnień.
  Widget _buildGlobalToggle(FeedReminderSettingsModel settings) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Activate All Reminders',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Switch(
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
            ],
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }

  /// Lista kontenerów przypomnień z opcjami wyboru czasu, przypisania zwierząt i aktywacji.
  List<Widget> _buildReminderContainers(FeedReminderSettingsModel settings) {
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
                  _buildReminderToggle(reminder),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 12.0),
                    child: _buildTimePicker(reminder),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: _buildPetSelection(reminder),
                  ),
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

  /// Przełącznik aktywacji/deaktywacji indywidualnego przypomnienia.
  Widget _buildReminderToggle(ReminderSetting reminder) {
    return SwitchListTile(
      title: const Text('Activate Reminder'),
      value: reminder.isActive,
      activeColor: Theme.of(context).primaryColorDark,
      onChanged: (value) {
        setState(() {
          reminder.isActive = value;
        });
      },
    );
  }

  /// Selektor czasu przypomnienia.
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

  /// Selektor zwierząt dla przypomnienia.
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

  Future<void> _saveReminder(FeedReminderSettingsModel settings) async {
    // Anulujemy wszystkie powiadomienia przypomnień o karmieniu
    await _cancelFeedNotifications(settings.reminders);

    // Zapisujemy nowe ustawienia w bazie danych
    await ref.read(reminderServiceProvider).saveFeedReminderSettings(settings);

    // Tworzymy nowe powiadomienia na podstawie aktualnych ustawień
    for (var reminder in settings.reminders) {
      if (reminder.isActive) {
        await NotificationService().createDailyNotification(
          id: reminder.hashCode,
          title: 'Feed Reminder',
          body: 'It\'s time to feed your pet!',
          time: reminder.time,
        );
        debugPrint(
            'Utworzono powiadomienie: ID=${reminder.hashCode}, czas=${reminder.time}');
      }
    }

    Navigator.pop(context);
  }

  /// Funkcja anulująca tylko powiadomienia przypomnień o karmieniu
  Future<void> _cancelFeedNotifications(List<ReminderSetting> reminders) async {
    for (var reminder in reminders) {
      await NotificationService().cancelNotification(reminder.hashCode);
      debugPrint('Anulowano powiadomienie: ID=${reminder.hashCode}');
    }
  }
}
