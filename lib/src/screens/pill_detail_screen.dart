import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/main.dart';
import 'package:pet_diary/src/components/events/pill/dosage_pet_details.dart';
import 'package:pet_diary/src/components/events/pill/end_date_pill_details.dart';
import 'package:pet_diary/src/components/events/pill/frequency_pill_details.dart';
import 'package:pet_diary/src/components/events/pill/name_pill_details.dart';
import 'package:pet_diary/src/components/events/pill/pill_emoji_details.dart';
import 'package:pet_diary/src/components/events/pill/reminders_pill_details.dart';
import 'package:pet_diary/src/components/events/pill/start_date_pill_details.dart';
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

bool cleanerOfFields = false;

class PillDetailScreen extends ConsumerStatefulWidget {
  final Pill? pill;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String petId;
  final String pillId;

  PillDetailScreen(this.petId, this.pillId, {super.key, this.pill});

  @override
  createState() => _PillDetailScreenState();
}

class _PillDetailScreenState extends ConsumerState<PillDetailScreen> {
  double containerHeight = 450;

  void toggleContainerHeight(bool showMore) {
    setState(() {
      containerHeight = showMore ? 560 : 440;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pill != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pillNameControllerProvider).text = widget.pill!.name;
        if (ref.read(pillDateControllerProvider.notifier).state !=
            widget.pill!.addDate) {
          ref.read(pillDateControllerProvider.notifier).state =
              widget.pill!.addDate ?? DateTime.now();
        }
        if (widget.pill!.frequency != null) {
          ref.read(pillFrequencyProvider.notifier).state =
              int.tryParse(widget.pill!.frequency!);
        }
        if (widget.pill!.dosage != null) {
          ref.read(pillDosageProvider.notifier).state =
              int.tryParse(widget.pill!.dosage!);
        }

        if (widget.pill!.startDate != null) {
          ref.read(pillStartDateControllerProvider.notifier).state =
              widget.pill!.startDate ?? DateTime.now();
        }

        if (widget.pill!.endDate != null) {
          ref.read(pillEndDateControllerProvider.notifier).state =
              widget.pill!.endDate ?? DateTime.now();
        }

        if (widget.pill!.emoji.isNotEmpty) {
          ref.read(pillEmojiProvider).text = widget.pill!.emoji;
        }

        cleanerOfFields = true;
      });
    } else if (ModalRoute.of(context)!.isCurrent &&
        widget.pill == null &&
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
        ref.read(pillEmojiProvider).text = '';

        cleanerOfFields = false;
      });
    }

    return WillPopScope(
      onWillPop: () async {
        ref
            .read(temporaryReminderIds.notifier)
            .state!
            .clear(); // Czyszczenie tymczasowych przypomnień
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pill == null
                ? 'N e w   m e d i c i n e'
                : 'E d i t   m e d i c i n e',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 50,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
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
                          child: const NamePillDetails(),
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
                                child: const FrequencyPillDetails(),
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
                                child: const StartDatePillDetails(),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const EndDatePillDetails(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        EmojiPillDetails(
                          onShowMoreChanged: toggleContainerHeight,
                        ),
                        const SizedBox(height: 15),
                        remindersPillDetails(ref, context, widget.petId,
                            widget.pillId, widget.pill),
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
                            .where(
                                (element) => element.objectId == widget.pillId)
                            .toList();
                      } else if (widget.pill != null) {
                        reminders = snapshot.data!
                            .where((element) =>
                                element.objectId == widget.pill!.id)
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
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => savePill(context, ref, widget.formKey,
                      widget.petId, widget.pillId, widget.pill),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff68a2b6)),
                    minimumSize: MaterialStateProperty.all(const Size(300, 40)),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.save,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                  ),
                  label: Text(
                    ' Save',
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                      fontSize: 20,
                    ),
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
  Pill? pill,
) async {
  DateTime startDate = ref.read(pillStartDateControllerProvider);
  DateTime endDate = ref.read(pillEndDateControllerProvider);
  String name = ref.read(pillNameControllerProvider).text;
  int? frequency = ref.read(pillFrequencyProvider);
  int? dosage = ref.read(pillDosageProvider);
  TextEditingController emoji = ref.read(pillEmojiProvider);

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
    final Pill newPill =
        isNewPill ? Pill(name: '', eventId: '', petId: '') : pill;
    final TextEditingController nameController =
        ref.read(pillNameControllerProvider);

    List<Reminder> newPillRemindersList =
        await ref.read(reminderServiceProvider).getReminders();

    newPillRemindersList = newPillRemindersList
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
          ref.read(reminderSelectedRepeatType),
          reminder.repeatInterval,
          reminder.selectedDays,
        );
      }
    }
    if (isNewPill) {
      Pet? pet = await ref.watch(petServiceProvider).getPetById(petId);
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
        description: newPill.name,
        proffesionId: 'BRAK',
        personId: 'BRAK',
        avatarImage: 'assets/images/dog_avatar_014.png',
        emoticon: '💊',
      );

      ref.read(eventServiceProvider).addEvent(newEvent);

      ref.read(temporaryReminderIds.notifier).state!.clear();

      cleanerOfFields = true;

      Navigator.of(context).pop(newPill);
    } else {
      Event? eventToUpdate =
          await ref.watch(eventServiceProvider).getEventById(pill.eventId);

      eventToUpdate!.title = nameController.text;

      ref.read(eventServiceProvider).updateEvent(eventToUpdate);

      pill.name = nameController.text;
      pill.addDate = ref.read(pillDateControllerProvider);
      pill.startDate = ref.read(pillStartDateControllerProvider);
      pill.endDate = ref.read(pillEndDateControllerProvider);
      pill.frequency = ref.read(pillFrequencyProvider).toString();
      pill.dosage = ref.read(pillDosageProvider).toString();
      pill.emoji = ref.read(pillEmojiProvider).text;

      List<Reminder> editingPillRemindersList =
          await ref.read(reminderServiceProvider).getReminders();

      editingPillRemindersList = editingPillRemindersList
          .where((element) => element.objectId == pill.id)
          .toList();

      if (editingPillRemindersList.isNotEmpty) {
        for (var reminder in editingPillRemindersList) {
          String descriptionForReminder =
              '${reminder.title} - ${reminder.description}';

          await schedulePillReminder(
            flutterLocalNotificationsPlugin,
            pill.name,
            int.parse(generateUniqueIdWithinRange()),
            reminder.time,
            ref.read(pillEndDateControllerProvider),
            descriptionForReminder,
            ref.read(reminderSelectedRepeatType),
            reminder.repeatInterval,
            reminder.selectedDays,
          );
        }
      }

      ref.read(temporaryReminderIds.notifier).state!.clear();

      cleanerOfFields = true;

      Navigator.of(context).pop(pill);
    }
  }
}
