// ignore_for_file: unused_result, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/main.dart';
import 'package:pet_diary/src/components/pill_details/dosage_pet_details.dart';
import 'package:pet_diary/src/components/pill_details/end_date_pill_details.dart';
import 'package:pet_diary/src/components/pill_details/frequency_pill_details.dart';
import 'package:pet_diary/src/components/pill_details/name_pill_details.dart';
import 'package:pet_diary/src/components/pill_details/pill_emoji_details.dart';
import 'package:pet_diary/src/components/pill_details/start_date_pill_details.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/helper/schedule_notification.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import '../providers/pills_provider.dart';

// nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
bool cleanerOfFields = false;

// A screen for adding or editing pill details.
// ignore: must_be_immutable
class PillDetailScreen extends ConsumerWidget {
  final Pill? pill;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String petId;
  TimeOfDay? selectedTime;
  String? reminderTitle;
  String? reminderDescription;
  List<Reminder> reminders = [];
  var newPillId = generateUniqueId();
  List<String> tempReminderIds = [];

  PillDetailScreen(this.petId, {super.key, this.pill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pill != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pillNameControllerProvider).text = pill!.name;
        // Setting the date only if it differs from the default value, to avoid overwriting user changes.
        if (ref.read(pillDateControllerProvider.notifier).state !=
            pill!.addDate) {
          ref.read(pillDateControllerProvider.notifier).state =
              pill!.addDate ?? DateTime.now();
        }
        if (pill!.frequency != null) {
          ref.read(pillFrequencyProvider.notifier).state =
              int.tryParse(pill!.frequency!);
        }
        if (pill!.dosage != null) {
          ref.read(pillDosageProvider.notifier).state =
              int.tryParse(pill!.dosage!);
        }

        if (pill!.startDate != null) {
          ref.read(pillStartDateControllerProvider.notifier).state =
              pill!.startDate ?? DateTime.now();
        }

        if (pill!.endDate != null) {
          ref.read(pillEndDateControllerProvider.notifier).state =
              pill!.endDate ?? DateTime.now();
        }

        if (pill!.emoji.isNotEmpty) {
          ref.read(pillEmojiProvider).text = pill!.emoji;
        }

        // nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
        cleanerOfFields = true;
      });
    } else if (ModalRoute.of(context)!.isCurrent &&
        pill == null &&
        cleanerOfFields) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DateTime today = DateTime.now();
        TimeOfDay? timeOfDay =
            TimeOfDay(hour: today.hour, minute: today.minute);

        ref.read(pillNameControllerProvider).text = '';

        ref.read(pillDateControllerProvider.notifier).state = today;
        ref.read(pillStartDateControllerProvider.notifier).state = today;
        ref.read(pillEndDateControllerProvider.notifier).state = today;

        ref.read(pillFrequencyProvider.notifier).state = 1;
        ref.read(pillDosageProvider.notifier).state = 1;

        ref.read(reminderNameControllerProvider).text = '';
        ref.read(reminderDescriptionControllerProvider).text = '';
        ref.read(reminderTimeOfDayControllerProvider.notifier).state =
            timeOfDay;
        ref.read(pillEmojiProvider).text = ' ';

        // nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
        cleanerOfFields = false;
      });
    }

    return WillPopScope(
        onWillPop: () async {
          // Tu możesz dodać logikę, którą chcesz wykonać, gdy użytkownik próbuje opuścić ekran
          // Na przykład, usuwanie niezapisanych powiadomień
          for (var id in tempReminderIds) {
            await ref
                .read(reminderRepositoryProvider)
                .value
                ?.deleteReminder(id);
          }
          // Zwróć true, aby zezwolić na opuszczenie ekranu
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              pill == null ? 'N e w  p i l l' : 'E d i t  p i l l',
              style: const TextStyle(fontSize: 20),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  const NamePillDetails(),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      FrequencyPillDetails(),
                      SizedBox(
                        height: 20,
                        width: 23,
                      ),
                      DosagePetDetails(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      StartDatePillDetails(),
                      SizedBox(
                        height: 20,
                        width: 23,
                      ),
                      EndDatePillDetails(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const EmojiPillDetails(),
                  const SizedBox(height: 30),
                  buildRemindersUI(
                      ref, context, petId, newPillId, pill, tempReminderIds),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        savePill(context, ref, formKey, petId, newPillId),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        minimumSize:
                            MaterialStateProperty.all(const Size(300, 50)),
                        textStyle: MaterialStateProperty.all(
                          TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 18),
                        ),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ))),
                    child: Text(
                      'S a v e',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Function to save or update pill details.
  Future<void> savePill(BuildContext context, WidgetRef ref,
      GlobalKey<FormState> formKey, String petId, String newPillId) async {
    DateTime startDate = ref.read(pillStartDateControllerProvider);
    DateTime endDate = ref.read(pillEndDateControllerProvider);
    var name = ref.read(pillNameControllerProvider).text;
    var frequency = ref.read(pillFrequencyProvider);
    var dosage = ref.read(pillDosageProvider);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (dosage == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dosage can not be zero.')),
      );
      return;
    }

    if (frequency == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Frequency can not be zero.')),
      );
      return;
    }

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('End date cannot be earlier than start date.')),
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      final bool isNewPill = pill == null;
      final Pill newPill = isNewPill ? Pill() : pill!;
      final TextEditingController nameController =
          ref.read(pillNameControllerProvider);

      var newPillRemindersList = ref
          .read(reminderRepositoryProvider)
          .value!
          .getReminders()
          .where((element) => element.objectId == newPillId)
          .toList();

      if (newPillRemindersList.isNotEmpty) {
        for (var reminder in newPillRemindersList) {
          await schedulePillReminder(
              flutterLocalNotificationsPlugin,
              reminder.title,
              int.parse(generateUniqueIdWithinRange()),
              reminder.time,
              ref.read(pillEndDateControllerProvider),
              reminder.description,
              ref.read(reminderSelectedRepeatType));
        }
      }
      if (isNewPill) {
        // Creating a new pill.
        final Pet? pet =
            ref.watch(petRepositoryProvider).value?.getPetById(petId);
        final String eventId = generateUniqueId();

        newPill.id = newPillId;
        newPill.name = nameController.text;
        newPill.addDate = ref.read(pillDateControllerProvider);
        newPill.startDate = ref.read(pillStartDateControllerProvider);
        newPill.endDate = ref.read(pillEndDateControllerProvider);
        newPill.eventId = eventId;
        newPill.petId = petId;
        newPill.frequency = ref.read(pillFrequencyProvider).toString();
        newPill.dosage = ref.read(pillDosageProvider).toString();
        newPill.emoji = ref.read(pillEmojiProvider).text;

        final Event newEvent = Event(
            id: eventId,
            title: newPill.name,
            description: newPill.addDate.toString(),
            date: DateTime.now(),
            durationTime: 0,
            value: 0,
            userId: pet!.userId,
            petId: petId,
            weightId: '',
            temperatureId: '',
            walkId: '',
            waterId: '',
            noteId: '',
            pillId: newPill.id);

        ref.read(eventRepositoryProvider).value?.addEvent(newEvent);
        ref.refresh(eventRepositoryProvider);

        // nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
        cleanerOfFields = true;

        Navigator.of(context).pop(newPill);
      } else {
        // Updating an existing pill.
        Event? eventToUpdate = ref
            .watch(eventRepositoryProvider)
            .value
            ?.getEventById(pill!.eventId);

        eventToUpdate!.title = nameController.text;
        eventToUpdate.description =
            ref.read(pillDateControllerProvider).toString();

        ref.read(eventRepositoryProvider).value?.updateEvent(eventToUpdate);

        pill?.name = nameController.text;
        pill?.addDate = ref.read(pillDateControllerProvider);
        pill?.startDate = ref.read(pillStartDateControllerProvider);
        pill?.endDate = ref.read(pillEndDateControllerProvider);
        pill?.frequency = ref.read(pillFrequencyProvider).toString();
        pill?.dosage = ref.read(pillDosageProvider).toString();
        pill?.emoji = ref.read(pillEmojiProvider).text;

        ref.refresh(eventRepositoryProvider);

        var editingPillRemindersList = ref
            .read(reminderRepositoryProvider)
            .value!
            .getReminders()
            .where((element) => element.objectId == pill!.id)
            .toList();
        if (editingPillRemindersList.isNotEmpty) {
          for (var reminder in editingPillRemindersList) {
            var descriptionForReminder =
                '${reminder.title} - ${reminder.description}';

            await schedulePillReminder(
                flutterLocalNotificationsPlugin,
                pill!.name,
                int.parse(generateUniqueIdWithinRange()),
                reminder.time,
                ref.read(pillEndDateControllerProvider),
                descriptionForReminder,
                ref.read(reminderSelectedRepeatType));
          }
        }

        // nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
        cleanerOfFields = true;
        Navigator.of(context).pop(pill);
      }
    }
  }
}

Widget buildRemindersUI(WidgetRef ref, BuildContext context, String petId,
    String newPillId, final Pill? pill, List<String> tempReminderIds) {
  final reminderRepoAsyncValue = ref.watch(reminderRepositoryProvider);

  return reminderRepoAsyncValue.when(
    data: (reminderRepo) {
      var perpetumMobile = newPillId;

      if (pill != null) {
        perpetumMobile = pill.id;
      }

      List<Reminder> reminders = reminderRepo
          .getReminders()
          .where((element) => element.objectId == perpetumMobile)
          .toList();

      return Column(
        children: [
          SizedBox(
            height: 50,
            width: 230,
            child: FloatingActionButton.extended(
              onPressed: () {
                _showAddReminderDialog(
                    context, ref, petId, newPillId, pill, tempReminderIds);
              },
              label: Text(
                ' N e w  r e m i n d',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              icon: Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColorDark,
              ),
              backgroundColor: Colors.blue, // Customize color
              extendedPadding: const EdgeInsets.symmetric(
                horizontal: 10.0, // Adjust padding
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    15.0), // Adjust border radius as needed
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return reminderItem(reminder: reminder, ref: ref);
              },
            ),
          ),
        ],
      );
    },
    loading: () => const CircularProgressIndicator(),
    error: (e, st) => Text('Error: $e'),
  );
}

Future<void> _showAddReminderDialog(
    BuildContext context,
    WidgetRef ref,
    final String petId,
    final String newPillId,
    Pill? pill,
    List<String> tempReminderIds) async {
  String selectedRepeatType = ref.watch(reminderSelectedRepeatType);
  final TextEditingController nameController =
      ref.watch(reminderNameControllerProvider);
  final TextEditingController descriptionController =
      ref.watch(reminderDescriptionControllerProvider);
  TimeOfDay selectedTime = ref.watch(reminderTimeOfDayControllerProvider);

  final reminders = ref
      .read(reminderRepositoryProvider)
      .value
      ?.getReminders()
      .where((element) => element.objectId == newPillId)
      .toList();
  var labelStyle = TextStyle(color: Theme.of(context).primaryColorDark);

  if (reminders!.length >= 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Maximum number of reminders reached (10)'),
      ),
    );
    return;
  }
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            'R e m i n d e r',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Repeatability",
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: selectedRepeatType.isEmpty ? null : selectedRepeatType,
                  hint: Text("R", style: labelStyle),
                  items: <String>[
                    'Once',
                    'Daily',
                    'Weekly',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRepeatType = newValue!;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time selector',
                    labelStyle: labelStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ), // Odpowiednie paddingi dla Twojego designu
                  ),
                  child: SizedBox(
                    height: 30,
                    width: double
                        .infinity, // Aby przycisk rozciągał się na całą szerokość
                    child: ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors
                                        .black, // Kolor tekstu przycisku 'OK'
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        selectedTime.format(
                            context), // Formatowanie czasu do czytelnej formy
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                // Logika dodawania przypomnienia do repo
                final Reminder newReminder = Reminder(
                  id: generateUniqueId(),
                  title: nameController.text,
                  description: descriptionController.text,
                  time: selectedTime,
                  userId: ref
                      .read(petRepositoryProvider)
                      .value!
                      .getPetById(petId)!
                      .userId,
                  objectId: newPillId,
                );

                if (pill != null) {
                  newReminder.objectId = pill.id;
                }

                ref.watch(reminderSelectedRepeatType.notifier).state =
                    selectedRepeatType;

                ref
                    .read(reminderRepositoryProvider)
                    .value
                    ?.addReminder(newReminder);

                ref.refresh(reminderRepositoryProvider);

                DateTime today = DateTime.now();
                TimeOfDay? timeOfDay =
                    TimeOfDay(hour: today.hour, minute: today.minute);

                // nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
                cleanerOfFields = false;

                ref.read(reminderNameControllerProvider).text = '';
                ref.read(reminderDescriptionControllerProvider).text = '';
                ref.read(reminderTimeOfDayControllerProvider.notifier).state =
                    timeOfDay;

                tempReminderIds.add(newReminder.id);

                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    },
  );
}

Widget reminderItem({required Reminder reminder, required WidgetRef ref}) {
  return ListTile(
    title: Text(reminder.title),
    subtitle: Text(
        '${reminder.time.hour}:${reminder.time.minute} - ${reminder.description}'),
    trailing: IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await ref
            .read(reminderRepositoryProvider.future)
            .then((reminderRepo) => reminderRepo.deleteReminder(reminder.id));
        ref.refresh(reminderRepositoryProvider);
      },
    ),
  );
}
