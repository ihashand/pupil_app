import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/components/events/event_medicine/show_add_medicine.dart';
import 'package:pet_diary/src/components/events/event_medicine/show_add_medicine_name.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_reminder_provider.dart';
import 'package:pet_diary/src/screens/medicine_screens/medicine_add_edit_screen.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  final String petId;

  const MedicineScreen(this.petId, {super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen> {
  late Future<List<Event>> _eventsFuture;

  bool isCurrentSelected = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventsFuture = ref.read(eventsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    var newPillId = generateUniqueId();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        title: Text(
          'M E D I C I N E',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark,
              size: 24,
            ),
            // Poprawienie wywołania showAddMedicine
            onPressed: () => showAddMedicineName(context, ref, widget.petId),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.surface,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isCurrentSelected = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: isCurrentSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Current Medicine',
                            style: TextStyle(
                              color: isCurrentSelected
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isCurrentSelected = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: !isCurrentSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Medicine History',
                            style: TextStyle(
                              color: !isCurrentSelected
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Consumer(builder: (context, ref, _) {
              final asyncMedicines = ref.watch(eventMedicinesProvider);
              return asyncMedicines.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (allMedicines) {
                  final petMedicines = allMedicines
                      .where((element) =>
                          element.petId == widget.petId &&
                          (isCurrentSelected
                              ? element.isCurrent
                              : !element.isCurrent))
                      .toList();
                  if (petMedicines.isEmpty) {
                    return const Center(
                      child: Text('No medicine found.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: petMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = petMedicines[index];
                      return MedicineTile(
                        medicine: medicine,
                        onEdit: () => addOrEditMedicine(
                          context,
                          ref,
                          widget.petId,
                          newPillId,
                          medicine: medicine,
                        ),
                        onDelete: () => deletePill(context, ref, widget.petId,
                            medicine: medicine),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void addOrEditMedicine(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String newMedicineId, {
    EventMedicineModel? medicine,
  }) async {
    final bool isEditing = medicine != null;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineAddEditScreen(
          petId,
          newMedicineId,
          medicine: medicine,
        ),
      ),
    );
    if (result != null) {
      if (isEditing) {
        await ref.read(eventMedicineServiceProvider).updateMedicine(result);
      } else {
        await ref.read(eventMedicineServiceProvider).addMedicine(result);
      }
    }
  }

  void deletePill(
    BuildContext context,
    WidgetRef ref,
    String petId, {
    EventMedicineModel? medicine,
  }) async {
    List<EventReminderModel> pillRemindersList =
        await ref.read(eventReminderServiceProvider).getReminders();

    pillRemindersList = pillRemindersList
        .where((element) => element.objectId == medicine!.id)
        .toList();

    if (pillRemindersList.isNotEmpty) {
      for (var reminder in pillRemindersList) {
        await ref
            .read(eventReminderServiceProvider)
            .deleteReminder(reminder.id);
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    await ref.read(eventMedicineServiceProvider).deleteMedicine(medicine!.id);
    await ref.read(eventServiceProvider).deleteEvent(medicine.eventId);
  }
}

class MedicineTile extends StatelessWidget {
  final EventMedicineModel medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineTile({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return Card(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
      color: Theme.of(context).colorScheme.primary,
      child: ExpansionTile(
        shape: const Border(),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Text(
                    medicine.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    medicine.name,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColorDark,
                size: 17,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).primaryColorDark,
                size: 17,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, '💊',
                    '${medicine.dosage ?? 'Not provided'}', 'Dosage'),
                _buildInfoRow(context, '🔁',
                    '${medicine.frequency ?? 'Not provided'}', "Frequency"),
                _buildInfoRow(
                    context,
                    '📅',
                    dateFormat.format(medicine.addDate ?? DateTime.now()),
                    "Add date"),
                _buildInfoRow(
                    context,
                    '🛫',
                    dateFormat.format(medicine.startDate ?? DateTime.now()),
                    "Start date"),
                _buildInfoRow(
                    context,
                    '🏁',
                    dateFormat.format(medicine.endDate ?? DateTime.now()),
                    "End date"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String emoji, String firstText, String secondText) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 3),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    firstText,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  Text(
                    secondText,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}
