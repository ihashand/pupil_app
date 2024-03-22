// ignore_for_file: unused_result

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/screens/pill_detail_screen.dart';

// ignore: must_be_immutable
class PillsScreen extends ConsumerWidget {
  String petId;

  PillsScreen(this.petId, {super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final allPills = ref
        .watch(pillRepositoryProvider)
        .value
        ?.getPills()
        .where((element) => element.petId == petId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "M e d i c i n e",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => addOrEditPill(context, ref, petId),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    minimumSize: MaterialStateProperty.all(const Size(300, 50)),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 18),
                    ),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ))),
                child: Text(
                  'N e w  p i l l',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addOrEditPill(BuildContext context, WidgetRef ref, String petId,
      {Pill? pill}) async {
    final bool isEditing = pill != null; // Check if editing or adding new
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PillDetailScreen(
                petId,
                pill: pill,
              )),
    );
    if (result != null) {
      if (isEditing) {
        ref.read(pillRepositoryProvider).value?.updatePill(result);
      } else {
        ref.read(pillRepositoryProvider).value?.addPill(result);
      }
      ref.refresh(pillRepositoryProvider);
    }
  }

  void deletePill(BuildContext context, WidgetRef ref, String petId,
      {Pill? pill}) async {
    var pillRemindersList = ref
        .read(reminderRepositoryProvider)
        .value!
        .getReminders()
        .where((element) => element.objectId == pill!.id)
        .toList();

    if (pillRemindersList.isNotEmpty) {
      for (var reminder in pillRemindersList) {
        await ref
            .read(reminderRepositoryProvider)
            .value
            ?.deleteReminder(reminder.id);
      }
    }

    // Upewniamy się, że usunięcie zostało wykonane, zanim przejdziemy dalej
    await Future.delayed(const Duration(seconds: 1));

    await ref.read(pillRepositoryProvider).value?.deletePill(pill!.id);
    await ref.read(eventRepositoryProvider).value?.deleteEvent(pill!.eventId);

    ref.refresh(pillRepositoryProvider);
    ref.refresh(eventRepositoryProvider);
  }
}

class PillTile extends StatefulWidget {
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
  State<PillTile> createState() => _PillTileState();
}

class _PillTileState extends State<PillTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          ListTile(
            title: Text(widget.pill.name),
            leading: Text(
              widget.pill.emoji, // Emotikona tabletki
              style: const TextStyle(fontSize: 24),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                  color: Theme.of(context).primaryColorLight,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: ConstrainedBox(
              constraints: isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dosage: ${widget.pill.dosage}'),
                    Text('Frequency: ${widget.pill.frequency}'),
                    Text(
                        'Date added: ${dateFormat.format(widget.pill.addDate!)}'),
                    Text(
                        'Start date: ${dateFormat.format(widget.pill.startDate!)}'),
                    Text(
                        'End date: ${dateFormat.format(widget.pill.endDate!)}'),
                    // Możesz dodać więcej szczegółów związanych z lekiem
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
