import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'new_event_screen.dart';

class MyCalendarScreen extends ConsumerWidget {
  const MyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
    var dateController = ref.watch(eventDateControllerProvider);
    var nameController = ref.watch(eventNameControllerProvider);
    var descriptionController = ref.watch(eventDescriptionControllerProvider);

    var eventsOnSelectedDate = allEvents?.where((event) {
      return DateFormat('yyyy-MM-dd').format(event.date) ==
          DateFormat('yyyy-MM-dd').format(dateController);
    }).toList();

    void selectDate(DateTime date, DateTime focusedDate) {
      ref.read(eventDateControllerProvider.notifier).state = date;
      eventsOnSelectedDate = allEvents?.where((event) {
        return DateFormat('yyyy-MM-dd').format(event.date) ==
            DateFormat('yyyy-MM-dd').format(date);
      }).toList();
    }

    String formatDuration(int durationInMinutes) {
      int hours = durationInMinutes ~/ 60;
      int minutes = durationInMinutes % 60;

      String formattedDuration = '$hours:${minutes.toString().padLeft(2, '0')}';
      return formattedDuration;
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(height: 60),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: dateController,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(dateController, day);
            },
            onDaySelected: selectDate,
            locale: 'en_US',
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left,
                  color: Theme.of(context).colorScheme.inversePrimary),
              rightChevronIcon: Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        eventsOnSelectedDate![index].durationTime == 0
                            ? eventsOnSelectedDate![index].weight == 0
                                ? Text(eventsOnSelectedDate![index].description)
                                : Text(
                                    'Kg: ${(eventsOnSelectedDate![index].weight)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                            : Text(
                                'Duration: ${formatDuration(eventsOnSelectedDate![index].durationTime)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteEvent(
                          ref, allEvents, selectDate, dateController, index),
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewEventScreen(
                  context,
                  nameController,
                  descriptionController,
                  dateController,
                  ref,
                  allEvents,
                  selectDate),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void deleteEvent(
    WidgetRef ref,
    List<Event>? allEvents,
    void Function(DateTime date, DateTime focusedDate) selectDate,
    DateTime dateController,
    int index,
  ) async {
    await ref.watch(eventRepositoryProvider).value?.deleteEvent(index);
    allEvents = ref.refresh(eventRepositoryProvider).value?.getEvents();
    selectDate(dateController, dateController);
  }
}
