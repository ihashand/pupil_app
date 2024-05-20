import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/medicine_model.dart';
import 'package:pet_diary/src/notifiers/medicine_notifier.dart';
import 'package:pet_diary/src/screens/medicine_add_edit_screen.dart';

class MedicineScreen extends ConsumerWidget {
  final String petId;

  const MedicineScreen(this.petId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var newPillId = generateUniqueId();

    final medicines = ref
        .watch(medicineNotifierProvider)
        .where((element) => element.petId == petId)
        .toList();

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
            onPressed: () => addOrEditMedicine(context, ref, petId, newPillId),
            color: Theme.of(context).colorScheme.onPrimary,
            iconSize: 35,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: medicines.isEmpty
                ? const Center(child: Text('No medicine found.'))
                : ListView.builder(
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = medicines[index];
                      return MedicineTile(
                        medicine: medicine,
                        onEdit: () => addOrEditMedicine(
                          context,
                          ref,
                          petId,
                          medicine.id,
                          medicine: medicine,
                        ),
                        onDelete: () =>
                            deletePill(context, ref, petId, pill: medicine),
                      );
                    },
                  ),
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
      final notifier = ref.read(medicineNotifierProvider.notifier);
      if (isEditing) {
        await notifier.updateMedicine(result);
      } else {
        await notifier.addMedicine(result);
      }
    }
  }

  void deletePill(BuildContext context, WidgetRef ref, String petId,
      {Medicine? pill}) async {
    final notifier = ref.read(medicineNotifierProvider.notifier);
    await notifier.deleteMedicine(pill!.id);
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
                  'Date added: ${dateFormat.format(medicine.addDate)}',
                ),
                Text(
                  'Start date: ${dateFormat.format(medicine.startDate)}',
                ),
                Text(
                  'End date: ${dateFormat.format(medicine.endDate)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
