import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/others/event_delete_func.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';

class EventTile extends StatelessWidget {
  final Event event;
  final bool isExpanded;
  final WidgetRef ref;
  final String petId;

  const EventTile(
      {super.key,
      required this.event,
      required this.isExpanded,
      required this.ref,
      required this.petId});

  @override
  Widget build(BuildContext context) {
    String formattedStartTime = DateFormat('HH:mm').format(event.eventDate);
    String formattedDate = DateFormat('d MMM').format(event.eventDate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    Text(formattedDate, style: const TextStyle(fontSize: 11)),
                    Text(
                      formattedStartTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (event.emoticon.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 15),
                          child: Text(event.emoticon,
                              style: const TextStyle(fontSize: 32)),
                        ),
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign:
                              isExpanded ? TextAlign.left : TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    ...buildDescription(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () => navigateToScreen(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () =>
                              _showDeleteConfirmation(context, event, petId),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Event event, String petId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            TextButton(
              onPressed: () {
                // Assuming `ref` and `eventDeleteFunc` are accessible in this context.
                eventDeleteFunc(ref, context, [event], event.id, petId);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> buildDescription(BuildContext context) {
    if (event.vetVisitId.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 5),
          child: Text(
            event.description,
            style: const TextStyle(fontSize: 12),
          ),
        )
      ];
    }

    // Parse the description string into a Map
    final Map<String, dynamic> description =
        _parseDescription(event.description);

    return [
      Padding(
        padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.containsKey('visitReason'))
              _buildDescriptionRow('Reason', description['visitReason']),
            if (description.containsKey('symptoms'))
              _buildDescriptionRow('Symptoms', description['symptoms']),
            if (description.containsKey('vaccines'))
              _buildDescriptionRow('Vaccines', description['vaccines']),
            if (description.containsKey('followUpRequired'))
              _buildDescriptionRow(
                  'Follow-up Required', description['followUpRequired']),
            if (description.containsKey('followUpDate'))
              _buildDescriptionRow(
                  'Follow-up Date', description['followUpDate']),
            if (description.containsKey('notes'))
              _buildDescriptionRow('Notes', description['notes']),
          ],
        ),
      ),
    ];
  }

  void navigateToScreen(BuildContext context) {
    if (event.weightId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.temperatureId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.walkId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.waterId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.noteId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.pillId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.moodId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.stomachId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.psychicId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.stoolId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.urineId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.serviceId.isNotEmpty) {
      showWorkingProgress(context);
    } else if (event.careId.isNotEmpty) {
      showWorkingProgress(context);
    } else {
      showWorkingProgress(context);
    }
  }

  void showWorkingProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Work in progress, next update!')),
    );
  }

  Map<String, dynamic> _parseDescription(String description) {
    final Map<String, dynamic> parsedDescription = {};
    final List<String> pairs = description.split(',');
    for (String pair in pairs) {
      final List<String> keyValue = pair.split(':');
      if (keyValue.length == 2) {
        parsedDescription[keyValue[0].trim()] = keyValue[1].trim();
      }
    }
    return parsedDescription;
  }

  Widget _buildDescriptionRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
