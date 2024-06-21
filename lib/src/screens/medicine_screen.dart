import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/event_medicine_model.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';
import 'package:pet_diary/src/screens/medicine_add_edit_screen.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  final String petId;

  const MedicineScreen(this.petId, {super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventsFuture = ref.read(eventsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    var newPillId = generateUniqueId();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark,
        ),
        title: Text(
          'M e d i c i n e',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
            ),
            onPressed: () =>
                addOrEditMedicine(context, ref, widget.petId, newPillId),
            color: Theme.of(context).colorScheme.onPrimary,
            iconSize: 35,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(builder: (context, ref, _) {
              final asyncMedicines = ref.watch(eventMedicinesProvider);

              return asyncMedicines.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (allMedicines) {
                  final petMedicines = allMedicines
                      .where((element) => element.petId == widget.petId)
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

  // Method to add or edit medicine
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
    // Get all reminders
    List<EventReminderModel> pillRemindersList =
        await ref.read(eventReminderServiceProvider).getReminders();

    // Filter all reminders to find those related to the pill
    pillRemindersList = pillRemindersList
        .where((element) => element.objectId == medicine!.id)
        .toList();

    // Delete all reminders
    if (pillRemindersList.isNotEmpty) {
      for (var reminder in pillRemindersList) {
        await ref
            .read(eventReminderServiceProvider)
            .deleteReminder(reminder.id);
      }
    }

    // Wait for a while to ensure the deletion process
    await Future.delayed(const Duration(seconds: 1));
    // Delete the medicine and related event
    await ref.read(eventMedicineServiceProvider).deleteMedicine(medicine!.id);
    await ref.read(eventServiceProvider).deleteEvent(medicine.eventId);

    // Get all events
    final asyncEvents = await _eventsFuture;

    // Filter all events to find those referenced
    final relatedEvents =
        asyncEvents.where((event) => event.id == medicine.eventId).toList();

    // Delete all related events
    for (var event in relatedEvents) {
      await ref.read(eventServiceProvider).deleteEvent(event.id);
    }
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
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.primary,
      child: ExpansionTile(
        shape: const Border(), // Delete black lines on top and bootom of tile
        title: Row(
          children: [
            Text(
              medicine.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              medicine.name,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Theme.of(context).primaryColorDark,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Zmniejszony padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text('💊',
                            style: TextStyle(
                                fontSize: 20)), // Emotikon zamiast ikony
                        const SizedBox(width: 8),
                        Text(
                          'Dosage: ${medicine.dosage != 'null' ? medicine.dosage : 'Not provided'}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text('🔁',
                            style: TextStyle(
                                fontSize: 20)), // Emotikon zamiast ikony
                        const SizedBox(width: 8),
                        Text(
                          'Frequency: ${medicine.dosage != 'null' ? medicine.frequency : 'Not provided'}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text('📅',
                            style: TextStyle(
                                fontSize: 20)), // Emotikon zamiast ikony
                        const SizedBox(width: 8),
                        Text(
                          'Date added: ${dateFormat.format(medicine.addDate!)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text('🛫',
                            style: TextStyle(
                                fontSize: 20)), // Emotikon zamiast ikony
                        const SizedBox(width: 8),
                        Text(
                          'Start date: ${dateFormat.format(medicine.startDate!)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text('🏁',
                            style: TextStyle(
                                fontSize: 20)), // Emotikon zamiast ikony
                        const SizedBox(width: 8),
                        Text(
                          'End date: ${dateFormat.format(medicine.endDate!)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
