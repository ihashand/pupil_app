// ignore_for_file: unused_result

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/screens/pill_detail_screen.dart';

// ignore: must_be_immutable
class MedicineScreen extends ConsumerWidget {
  String petId;

  MedicineScreen(this.petId, {super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final allPills = ref.watch(pillRepositoryProvider).value?.getPills();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Management"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () => addOrEditPill(context, ref, petId),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
              child: Text(
                "A d d  P i l l",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allPills?.length,
              itemBuilder: (context, index) {
                final pill = allPills?[index];
                if (pill != null) {
                  return PillTile(
                    pill: pill,
                    onEdit: () => addOrEditPill(
                      context,
                      ref,
                      petId,
                      pill: pill,
                    ),
                    onDelete: () => deletePill(context, ref, petId, pill: pill),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  void addOrEditPill(BuildContext context, WidgetRef ref, String petId,
      {Pill? pill}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PillDetailScreen(
                petId,
                pill: pill,
              )),
    );
    if (result != null) {
      if (pill != null) {
        ref.read(pillRepositoryProvider).value?.updatePill(result);
      } else {
        ref.read(pillRepositoryProvider).value?.addPill(result);
      }
      ref.refresh(pillRepositoryProvider);
    }
  }

  void deletePill(BuildContext context, WidgetRef ref, String petId,
      {Pill? pill}) async {
    ref.read(pillRepositoryProvider).value?.deletePill(pill!.id);
    ref.read(eventRepositoryProvider).value?.deleteEvent(pill!.eventId);

    ref.refresh(pillRepositoryProvider);
    ref.refresh(eventRepositoryProvider);
  }
}

class PillTile extends StatelessWidget {
  final Pill pill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PillTile({
    super.key,
    required this.pill,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return ExpansionTile(
      title: Text(pill.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      children: [
        ListTile(
          subtitle: Text('''
                Dose:  ${pill.dosage}
                Frequency:  ${pill.frequency}
                Add date:  ${dateFormat.format(pill.addDate!)}
                Start date:  ${dateFormat.format(pill.startDate!)}
                End date:  ${dateFormat.format(pill.endDate!)}  '''),
        ),
      ],
    );
  }
}
