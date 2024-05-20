import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/medicine_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/medicine_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/screens/medicine_add_edit_screen.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  final String petId;

  const MedicineScreen(this.petId, {super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen> {
  @override
  Widget build(BuildContext context) {
    var newPillId = generateUniqueId();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        ),
        title: Text(
          'M e d i c i n e',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
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
              final asyncMedicines = ref.watch(medicinesProvider);

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
                            pill: medicine),
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
      BuildContext context, WidgetRef ref, String petId, String newMedicineId,
      {Medicine? medicine}) async {
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
        await ref
            .read(medicineServiceProvider)
            .updateMedicine(result); // Dodanie await
      } else {
        await ref
            .read(medicineServiceProvider)
            .addMedicine(result); // Dodanie await
      }
    }
  }

  void deletePill(BuildContext context, WidgetRef ref, String petId,
      {Medicine? pill}) async {
    List<Reminder> pillRemindersList =
        await ref.read(reminderServiceProvider).getReminders();

    pillRemindersList = pillRemindersList
        .where((element) => element.objectId == pill!.id)
        .toList();

    if (pillRemindersList.isNotEmpty) {
      for (var reminder in pillRemindersList) {
        await ref.read(reminderServiceProvider).deleteReminder(reminder.id);
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    await ref.read(medicineServiceProvider).deleteMedicine(pill!.id);
    await ref.read(eventServiceProvider).deleteEvent(pill.eventId);
  }
}

class MedicineTile extends StatelessWidget {
  final Medicine medicine;
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
        title: Row(
          children: [
            Text(
              medicine.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(medicine.name),
            const SizedBox(width: 12),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColorLight.withOpacity(0.7),
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Theme.of(context).primaryColorLight.withOpacity(0.7),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dosage: ${medicine.dosage}'),
                Text('Frequency: ${medicine.frequency}'),
                Text(
                  'Date added: ${dateFormat.format(medicine.addDate!)}',
                ),
                Text(
                  'Start date: ${dateFormat.format(medicine.startDate!)}',
                ),
                Text(
                  'End date: ${dateFormat.format(medicine.endDate!)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
