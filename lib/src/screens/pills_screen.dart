import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/screens/pill_detail_screen.dart';

class PillsScreen extends ConsumerWidget {
  final String petId;

  const PillsScreen(this.petId, {super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    var newPillId = generateUniqueId();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'M e d i c i n e',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Pill>>(
                stream: ref.read(pillServiceProvider).getPills(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    final allPills = snapshot.data!
                        .where((element) => element.petId == petId)
                        .toList();
                    if (allPills.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '💊',
                              style: TextStyle(fontSize: 40),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: allPills.length,
                      itemBuilder: (context, index) {
                        if (allPills.isNotEmpty) {
                          final pill = allPills[index];

                          return PillTile(
                            pill: pill,
                            onEdit: () => addOrEditPill(
                              context,
                              ref,
                              petId,
                              newPillId,
                              pill: pill,
                            ),
                            onDelete: () =>
                                deletePill(context, ref, petId, pill: pill),
                          );
                        }
                        return null;
                      },
                    );
                  } else {
                    return (const Text(
                        'If you see this, please raport this to admin pills_screen'));
                  }
                }),
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
              ElevatedButton.icon(
                onPressed: () => addOrEditPill(context, ref, petId, newPillId),
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
                  Icons.add,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                ),
                label: Text(
                  'Add new',
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                      fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addOrEditPill(
      BuildContext context, WidgetRef ref, String petId, String newPillId,
      {Pill? pill}) async {
    final bool isEditing = pill != null;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PillDetailScreen(
                petId,
                newPillId,
                pill: pill,
              )),
    );
    if (result != null) {
      if (isEditing) {
        ref.read(pillServiceProvider).updatePill(result);
      } else {
        ref.read(pillServiceProvider).addPill(result);
      }
    }
  }

  void deletePill(BuildContext context, WidgetRef ref, String petId,
      {Pill? pill}) async {
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

    await ref.read(pillServiceProvider).deletePill(pill!.id);
    await ref.read(eventServiceProvider).deleteEvent(pill.eventId);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              children: [
                Text(
                  widget.pill.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(widget.pill.name),
                const SizedBox(width: 12),
              ],
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
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dosage: ${widget.pill.dosage}'),
                  Text('Frequency: ${widget.pill.frequency}'),
                  Text(
                    'Date added: ${dateFormat.format(widget.pill.addDate!)}',
                  ),
                  Text(
                    'Start date: ${dateFormat.format(widget.pill.startDate!)}',
                  ),
                  Text(
                    'End date: ${dateFormat.format(widget.pill.endDate!)}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
