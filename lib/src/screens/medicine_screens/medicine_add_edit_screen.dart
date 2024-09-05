// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicinie_details_dosage.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicine_details_end_date.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicine_details_frequency.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicine_details_name.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicine_details_emoji.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicine_new_reminder_button.dart';
import 'package:pet_diary/src/components/events/event_medicine/medicine_details_start_date.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_reminder_provider.dart';
import '../../providers/events_providers/event_medicine_provider.dart';

bool cleanerOfFields = false;

class MedicineAddEditScreen extends ConsumerStatefulWidget {
  final EventMedicineModel? medicine;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String petId;
  final String medicineId;

  MedicineAddEditScreen(this.petId, this.medicineId,
      {super.key, this.medicine});

  @override
  createState() => _MedicineAddEditScreenState();
}

class _MedicineAddEditScreenState extends ConsumerState<MedicineAddEditScreen> {
  double containerHeight = 375;

  void toggleContainerHeight(bool showMore) {
    setState(() {
      containerHeight = showMore ? 485 : 375;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medicine != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(eventMedicineNameControllerProvider).text =
            widget.medicine!.name;
        if (ref.read(eventMedicineDateControllerProvider.notifier).state !=
            widget.medicine!.addDate) {
          ref.read(eventMedicineDateControllerProvider.notifier).state =
              widget.medicine!.addDate ?? DateTime.now();
        }
        if (widget.medicine!.frequency != null) {
          ref.read(eventMedicineFrequencyProvider.notifier).state =
              int.tryParse(widget.medicine!.frequency!);
        }
        if (widget.medicine!.dosage != null) {
          ref.read(eventMedicineDosageProvider.notifier).state =
              int.tryParse(widget.medicine!.dosage!);
        }

        if (widget.medicine!.startDate != null) {
          ref.read(eventMedicineStartDateControllerProvider.notifier).state =
              widget.medicine!.startDate ?? DateTime.now();
        }

        if (widget.medicine!.endDate != null) {
          ref.read(eventMedicineEndDateControllerProvider.notifier).state =
              widget.medicine!.endDate ?? DateTime.now();
        }

        if (widget.medicine!.emoji.isNotEmpty) {
          ref.read(eventMedicineEmojiProvider).text = widget.medicine!.emoji;
        }

        cleanerOfFields = true;
      });
    } else if (ModalRoute.of(context)!.isCurrent &&
        widget.medicine == null &&
        cleanerOfFields) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DateTime today = DateTime.now();
        TimeOfDay? timeOfDay =
            TimeOfDay(hour: today.hour, minute: today.minute);

        ref.read(eventMedicineNameControllerProvider).text = '';

        ref.read(eventMedicineDateControllerProvider.notifier).state = today;
        ref.read(eventMedicineStartDateControllerProvider.notifier).state =
            today;
        ref.read(eventMedicineEndDateControllerProvider.notifier).state = today;

        ref.read(eventMedicineFrequencyProvider.notifier).state = 1;
        ref.read(eventMedicineDosageProvider.notifier).state = 1;

        ref.read(eventReminderNameControllerProvider).text = '';
        ref.read(eventReminderDescriptionControllerProvider).text = '';
        ref.read(eventReminderTimeOfDayControllerProvider.notifier).state =
            timeOfDay;
        ref.read(eventMedicineEmojiProvider).text = '';

        cleanerOfFields = false;
      });
    }

    return PopScope(
      onPopInvoked: (pop) async {
        ref.read(eventReminderTemporaryIds.notifier).state!.clear();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Theme.of(context).primaryColorDark, size: 20),
          title: Text(
            widget.medicine == null
                ? 'N E W   M E D I C I N E'
                : 'E D I T  M E D I C I N E',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 50,
          actions: [
            IconButton(
              icon: Icon(
                Icons.check,
                color: Theme.of(context).primaryColorDark,
                size: 20,
              ),
              onPressed: () => savePill(context, ref, widget.formKey,
                  widget.petId, widget.medicineId, widget.medicine),
              iconSize: 20,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: containerHeight,
                    width: double.infinity,
                    child: Column(
                      children: [
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
                        MedicineDetailsEmoji(
                          onShowMoreChanged: toggleContainerHeight,
                        ),
                        medicineNewReminderButton(ref, context, widget.petId,
                            widget.medicineId, widget.medicine),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: Consumer(builder: (context, ref, _) {
                    final asyncReminders = ref.watch(eventRemindersProvider);
                    return asyncReminders.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (reminders) {
                        List<EventReminderModel> filteredReminders = [];
                        var tempReminderIds =
                            ref.watch(eventReminderTemporaryIds.notifier).state;

                        if (tempReminderIds != null &&
                            tempReminderIds.isNotEmpty) {
                          filteredReminders = reminders
                              .where((element) =>
                                  element.objectId == widget.medicineId)
                              .toList();
                        } else if (widget.medicine != null) {
                          filteredReminders = reminders
                              .where((element) =>
                                  element.objectId == widget.medicine!.id)
                              .toList();
                        }

                        if (filteredReminders.isEmpty) {
                          return const Center(
                              child: Text('No reminders available.'));
                        }

                        return ListView.builder(
                          itemCount: filteredReminders.length,
                          itemBuilder: (context, index) {
                            final reminder = filteredReminders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  reminder.title.isEmpty
                                      ? 'Medicine reminder'
                                      : '${reminder.title} reminder',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
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
                                        .read(eventReminderServiceProvider)
                                        .deleteReminder(reminder.id);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
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
  EventMedicineModel? pill,
) async {
  DateTime startDate = ref.read(eventMedicineStartDateControllerProvider);
  DateTime endDate = ref.read(eventMedicineEndDateControllerProvider);
  String name = ref.read(eventMedicineNameControllerProvider).text;
  int? frequency = ref.read(eventMedicineFrequencyProvider);
  int? dosage = ref.read(eventMedicineDosageProvider);
  TextEditingController emoji = ref.read(eventMedicineEmojiProvider);

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields.')),
    );
    return;
  }

  if (dosage == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dosage is not selected.')),
    );
    return;
  }

  if (frequency == 0) {
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
    final EventMedicineModel newPill = isNewPill
        ? EventMedicineModel(id: '', name: '', eventId: '', petId: '')
        : pill;
    final TextEditingController nameController =
        ref.read(eventMedicineNameControllerProvider);

    List<EventReminderModel> newPillRemindersList =
        await ref.read(eventReminderServiceProvider).getReminders();

    newPillRemindersList = newPillRemindersList
        .where((element) => element.objectId == newPillId)
        .toList();

    // if (newPillRemindersList.isNotEmpty) {
    //   for (var reminder in newPillRemindersList) {
    //     await schedulePillReminder(
    //       flutterLocalNotificationsPlugin,
    //       reminder.title,
    //       int.parse(generateUniqueIdWithinRange()),
    //       reminder.time,
    //       ref.read(eventMedicineEndDateControllerProvider),
    //       reminder.description,
    //       ref.read(eventReminderSelectedRepeatType),
    //       reminder.repeatInterval,
    //       reminder.selectedDays,
    //     );
    //   }
    // }
    if (isNewPill) {
      Pet? pet = await ref.watch(petServiceProvider).getPetById(petId);
      final String eventId = generateUniqueId();

      newPill.id = newPillId;
      newPill.name = nameController.text;
      newPill.addDate = ref.read(eventMedicineDateControllerProvider);
      newPill.startDate = ref.read(eventMedicineStartDateControllerProvider);
      newPill.endDate = ref.read(eventMedicineEndDateControllerProvider);
      newPill.eventId = eventId;
      newPill.petId = petId;
      newPill.frequency = ref.read(eventMedicineFrequencyProvider).toString();
      newPill.dosage = ref.read(eventMedicineDosageProvider).toString();
      newPill.emoji = ref.read(eventMedicineEmojiProvider).text;

      final Event newEvent = Event(
        id: eventId,
        title: newPill.name,
        eventDate: DateTime.now(),
        dateWhenEventAdded: newPill.addDate!,
        userId: pet!.userId,
        petId: petId,
        weightId: '',
        temperatureId: '',
        walkId: '',
        waterId: '',
        noteId: '',
        pillId: newPill.id,
        moodId: '',
        stomachId: '',
        description: newPill.name,
        proffesionId: 'BRAK',
        personId: 'BRAK',
        avatarImage: 'assets/images/dog_avatar_014.png',
        emoticon: '💊',
        psychicId: '',
        stoolId: '',
        urineId: '',
        serviceId: '',
        careId: '',
      );

      await ref.read(eventServiceProvider).addEvent(newEvent);

      ref.read(eventReminderTemporaryIds.notifier).state!.clear();

      cleanerOfFields = true;

      Navigator.of(context).pop(newPill);
    } else {
      Event? eventToUpdate =
          await ref.watch(eventServiceProvider).getEventById(pill.eventId);

      eventToUpdate!.title = nameController.text;

      await ref.read(eventServiceProvider).updateEvent(eventToUpdate);

      pill.name = nameController.text;
      pill.addDate = ref.read(eventMedicineDateControllerProvider);
      pill.startDate = ref.read(eventMedicineStartDateControllerProvider);
      pill.endDate = ref.read(eventMedicineEndDateControllerProvider);
      pill.frequency = ref.read(eventMedicineFrequencyProvider).toString();
      pill.dosage = ref.read(eventMedicineDosageProvider).toString();
      pill.emoji = ref.read(eventMedicineEmojiProvider).text;

      List<EventReminderModel> editingPillRemindersList =
          await ref.read(eventReminderServiceProvider).getReminders();

      editingPillRemindersList = editingPillRemindersList
          .where((element) => element.objectId == pill.id)
          .toList();

      // if (editingPillRemindersList.isNotEmpty) {
      //   for (var reminder in editingPillRemindersList) {
      //     String descriptionForReminder =
      //         '${reminder.title} - ${reminder.description}';

      //     await schedulePillReminder(
      //       flutterLocalNotificationsPlugin,
      //       pill.name,
      //       int.parse(generateUniqueIdWithinRange()),
      //       reminder.time,
      //       ref.read(eventMedicineEndDateControllerProvider),
      //       descriptionForReminder,
      //       ref.read(eventReminderSelectedRepeatType),
      //       reminder.repeatInterval,
      //       reminder.selectedDays,
      //     );
      //   }
      // }

      ref.read(eventReminderTemporaryIds.notifier).state!.clear();

      cleanerOfFields = true;

      Navigator.of(context).pop(pill);
    }
  }
}
