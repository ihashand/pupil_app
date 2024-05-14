import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/delete_event.dart';
import 'package:pet_diary/src/models/event_model.dart';

class EventListItemBuilder extends StatelessWidget {
  const EventListItemBuilder({
    super.key,
    required this.ref,
    required this.context,
    required this.event,
    required this.petEvents,
  });

  final WidgetRef ref;
  final BuildContext context;
  final Event event;
  final List<Event> petEvents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Text(
            event.emoticon,
            style: const TextStyle(fontSize: 22),
          ),
          title: Text(event.title),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deleteEvents(ref, context, petEvents, event.id),
          ),
        ),
      ),
    );
  }
}
