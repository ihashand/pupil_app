import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/main.dart';
import 'package:pet_diary/src/components/events/medicine/medicinie_details_dosage.dart';
import 'package:pet_diary/src/components/events/medicine/medicine_details_end_date.dart';
import 'package:pet_diary/src/components/events/medicine/medicine_details_frequency.dart';
import 'package:pet_diary/src/components/events/medicine/medicine_details_name.dart';
import 'package:pet_diary/src/components/events/medicine/medicine_details_emoji.dart';
import 'package:pet_diary/src/components/events/medicine/medicine_new_reminder_button.dart';
import 'package:pet_diary/src/components/events/medicine/medicine_details_start_date.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/helper/schedule_notification.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/medicine_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import '../providers/medicine_provider.dart';

bool cleanerOfFields = false;

class MedicineAddEditScreen extends ConsumerStatefulWidget {
  final Medicine? medicine;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String petId;
  final String medicineId;

  MedicineAddEditScreen(this.petId, this.medicineId,
      {super.key, this.medicine});

  @override
  createState() => _MedicineAddEditScreenState();
}

class _MedicineAddEditScreenState extends ConsumerState<MedicineAddEditScreen> {
  double containerHeight = 450;

  void toggleContainerHeight(bool showMore) {
    setState(() {
      containerHeight = showMore ? 590 : 450;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medicine != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(medicineNameControllerProvider).text = widget.medicine!.name;
        ref.read(medicineDateControllerProvider.notifier).state =
            widget.medicine!.addDate;
        ref.read(medicineFrequencyProvider.notifier).state =
            int.tryParse(widget.medicine!.frequency);
        ref.read(medicineDosageProvider.notifier).state =
            int.tryParse(widget.medicine!.dosage);
        ref.read(medicineStartDateControllerProvider.notifier).state =
            widget.medicine!.startDate;
        ref.read(medicineEndDateControllerProvider.notifier).state =
            widget.medicine!.endDate;
        ref.read(medicineEmojiProvider).text = widget.medicine!.emoji;

        cleanerOfFields = true;
      });
    } else if (ModalRoute.of(context)!.isCurrent &&
        widget.medicine == null &&
        cleanerOfFields) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DateTime today = DateTime.now();
        TimeOfDay? timeOfDay =
            TimeOfDay(hour: today.hour, minute: today.minute);

        ref.read(medicineNameControllerProvider).text = '';
        ref.read(medicineDateControllerProvider.notifier).state = today;
        ref.read(medicineStartDateControllerProvider.notifier).state = today;
        ref.read(medicineEndDateControllerProvider.notifier).state = today;
        ref.read(medicineFrequencyProvider.notifier).state = 1;
        ref.read(medicineDosageProvider.notifier).state = 1;
        ref.read(reminderNameControllerProvider).text = '';
        ref.read(reminderDescriptionControllerProvider).text = '';
        ref.read(reminderTimeOfDayControllerProvider.notifier).state =
            timeOfDay;
        ref.read(medicineEmojiProvider).text = '';

        cleanerOfFields = false;
      });
    }

    return PopScope(
      // Cleaning of temporary reminders, we need them to be removed when user presses back button
      onPopInvoked: (pop) async {
        ref.read(temporaryReminderIds.notifier).state!.clear();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
          ),
          title: Text(
            widget.medicine == null
                ? 'N e w   m e d i c i n e'
                : 'E d i t   m e d i c i n e',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 50,
          actions: [
            IconButton(
              icon: Icon(
                Icons.check,
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
              ),
              onPressed: () => savePill(context, ref, widget.formKey,
                  widget.petId, widget.medicineId, widget.medicine),
              color: Theme.of(context).colorScheme.onPrimary,
              iconSize: 35,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: containerHeight,
                    width: 500,
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const MedicinieDetailsName(),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const MedicinieDetailsFrequency(),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const DosagePetDetails(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const MedicineDetailsStartDate(),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const MedicinieDetailsEndDate(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        MedicineDetailsEmoji(
                          onShowMoreChanged: toggleContainerHeight,
                        ),
                        const SizedBox(height: 15),
                        medicineNewReminderButton(ref, context, widget.petId,
                            widget.medicineId, widget.medicine),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: StreamBuilder<List<Reminder>>(
                    stream:
                        ref.read(reminderServiceProvider).getRemindersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No reminders available.'));
                      }
                      List<Reminder> reminders = [];
                      var test = ref.watch(temporaryReminderIds.notifier).state;
                      if (test != null && test.isNotEmpty) {
                        reminders = snapshot.data!
                            .where((element) =>
                                element.objectId == widget.medicineId)
                            .toList();
                      } else if (widget.medicine != null) {
                        reminders = snapshot.data!
                            .where((element) =>
                                element.objectId == widget.medicine!.id)
                            .toList();
                      }
                      return ListView.builder(
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = reminders[index];
                          return ListTile(
                            title: Text(
                              reminder.title.isEmpty
                                  ? 'Medicine reminder'
                                  : '${reminder.title} reminder',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time: ${reminder.time.hour}:${reminder.time.minute} ',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  reminder.description,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await ref
                                    .read(reminderServiceProvider)
                                    .deleteReminder(reminder.id);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> savePill(
  BuildContext context,
  WidgetRef ref,
  GlobalKey<FormState> formKey,
  String petId,
  String newPillId,
  Medicine? pill,
) async {
  DateTime startDate = ref.read(medicineStartDateControllerProvider);
  DateTime endDate = ref.read(medicineEndDateControllerProvider);
  String name = ref.read(medicineNameControllerProvider).text;
  String? frequency = ref.read(medicineFrequencyProvider)?.toString();
  String? dosage = ref.read(medicineDosageProvider)?.toString();
  TextEditingController emoji = ref.read(medicineEmojiProvider);

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields.')),
    );
    return;
  }

  if (dosage == '0') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dosage is not selected.')),
    );
    return;
  }

  if (frequency == '0') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Frequency is not selected.')),
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

  if (emoji.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Emoji is not selected. Please enter an emoji.')),
    );
    return;
  }

  if (formKey.currentState!.validate()) {
    final bool isNewPill = pill == null;
    final TextEditingController nameController =
        ref.read(medicineNameControllerProvider);

    List<Reminder> newPillRemindersList =
        await ref.read(reminderServiceProvider).getReminders();

    newPillRemindersList = newPillRemindersList
        .where((element) => element.objectId == newPillId)
        .toList();

    // Schedule reminders
    for (var reminder in newPillRemindersList) {
      schedulePillReminder(
        flutterLocalNotificationsPlugin,
        reminder.title,
        int.parse(generateUniqueIdWithinRange()),
        reminder.time,
        ref.read(medicineEndDateControllerProvider),
        reminder.description,
        ref.read(reminderSelectedRepeatType),
        reminder.repeatInterval,
        reminder.selectedDays,
      );
    }

    if (isNewPill) {
      Pet? pet = await ref.watch(petServiceProvider).getPetById(petId);
      final String eventId = generateUniqueId();

      final Medicine newPill = Medicine(
        id: newPillId,
        name: nameController.text,
        addDate: ref.read(medicineDateControllerProvider),
        startDate: ref.read(medicineStartDateControllerProvider),
        endDate: ref.read(medicineEndDateControllerProvider),
        dosage: ref.read(medicineDosageProvider).toString(),
        frequency: ref.read(medicineFrequencyProvider).toString(),
        emoji: ref.read(medicineEmojiProvider).text,
        eventId: eventId,
        petId: petId,
      );

      final Event newEvent = Event(
        id: eventId,
        title: newPill.name,
        eventDate: DateTime.now(),
        dateWhenEventAdded: newPill.addDate,
        userId: pet!.userId,
        petId: petId,
        weightId: '',
        temperatureId: '',
        walkId: '',
        waterId: '',
        noteId: '',
        pillId: newPill.id,
        description: newPill.name,
        proffesionId: 'BRAK',
        personId: 'BRAK',
        avatarImage: 'assets/images/dog_avatar_014.png',
        emoticon: '💊',
      );

      // Update local database first
      // await ref.read(localMedicineServiceProvider).addMedicine(newPill);
      // Then update remote database
      //ref.read(eventServiceProvider).addEvent(newEvent);

      ref.read(temporaryReminderIds.notifier).state!.clear();
      cleanerOfFields = true;

      Navigator.of(context).pop(newPill);
    } else {
      Event? eventToUpdate =
          await ref.watch(eventServiceProvider).getEventById(pill.eventId);

      eventToUpdate!.title = nameController.text;

      await ref.read(eventServiceProvider).updateEvent(eventToUpdate);

      pill.name = nameController.text;
      pill.addDate = ref.read(medicineDateControllerProvider);
      pill.startDate = ref.read(medicineStartDateControllerProvider);
      pill.endDate = ref.read(medicineEndDateControllerProvider);
      pill.frequency = ref.read(medicineFrequencyProvider).toString();
      pill.dosage = ref.read(medicineDosageProvider).toString();
      pill.emoji = ref.read(medicineEmojiProvider).text;

      List<Reminder> editingPillRemindersList =
          await ref.read(reminderServiceProvider).getReminders();

      editingPillRemindersList = editingPillRemindersList
          .where((element) => element.objectId == pill.id)
          .toList();

      for (var reminder in editingPillRemindersList) {
        String descriptionForReminder =
            '${reminder.title} - ${reminder.description}';

        schedulePillReminder(
          flutterLocalNotificationsPlugin,
          pill.name,
          int.parse(generateUniqueIdWithinRange()),
          reminder.time,
          ref.read(medicineEndDateControllerProvider),
          descriptionForReminder,
          ref.read(reminderSelectedRepeatType),
          reminder.repeatInterval,
          reminder.selectedDays,
        );
      }

      ref.read(temporaryReminderIds.notifier).state!.clear();
      cleanerOfFields = true;

      Navigator.of(context).pop(pill);
    }
  }
}
