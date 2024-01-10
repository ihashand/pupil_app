import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCalendarScreen extends ConsumerWidget {
  const MyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetching all events
    var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
    var dateController = ref.watch(eventDateControllerProvider);
    var nameController = ref.watch(eventNameControllerProvider);
    var descriptionController = ref.watch(eventDescriptionControllerProvider);

    // Filtering events based on selected date
    var eventsOnSelectedDate = allEvents?.where((event) {
      return DateFormat('yyyy-MM-dd').format(event.date) ==
          DateFormat('yyyy-MM-dd').format(dateController);
    }).toList();

    // Function to handle date selection
    void selectDate(DateTime date, DateTime focusedDate) {
      ref.read(eventDateControllerProvider.notifier).state = date;
      // Refresh events for the selected date
      eventsOnSelectedDate = allEvents?.where((event) {
        return DateFormat('yyyy-MM-dd').format(event.date) ==
            DateFormat('yyyy-MM-dd').format(date);
      }).toList();
    }

    // Function to add new event
    Future<void> addNewEvent() async {
      String eventName = nameController.text.trim();
      String eventDescription = descriptionController.text.trim();

      if (eventName.isNotEmpty && eventDescription.isNotEmpty) {
        Event newEvent = Event(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: eventName,
          description: eventDescription,
          date: dateController,
        );
        await ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
        nameController.clear();
        descriptionController.clear();
        allEvents = ref.refresh(eventRepositoryProvider).value?.getEvents();
        selectDate(dateController, dateController);
      }
    }

    // Function to delete an event
    Future<void> deleteEvent(int index) async {
      await ref.watch(eventRepositoryProvider).value?.deleteEvent(index);
      allEvents = ref.refresh(eventRepositoryProvider).value?.getEvents();
      selectDate(dateController, dateController);
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(height: 60),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            startingDayOfWeek: StartingDayOfWeek.monday,
            focusedDay: dateController,
            calendarFormat: CalendarFormat.month,
            onDaySelected: selectDate,
            selectedDayPredicate: (day) => isSameDay(day, dateController),
          ),
          const SizedBox(height: 20),
          Text(
            'Events for ${DateFormat('dd/MM/yyyy').format(dateController)}:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: eventsOnSelectedDate?.length ?? 0,
              itemBuilder: (context, index) {
                if (eventsOnSelectedDate == null ||
                    eventsOnSelectedDate!.isEmpty) {
                  return const ListTile(
                    title: Text("No events on this date"),
                  );
                } else {
                  return ListTile(
                    title: Text(eventsOnSelectedDate![index].title),
                    subtitle: Text(eventsOnSelectedDate![index].description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteEvent(index),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add New Event'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Event Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Event Description'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addNewEvent();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
