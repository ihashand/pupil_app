import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/create_event_module.dart';
import 'package:pet_diary/src/components/events/delete_event_module.dart';
import 'package:pet_diary/src/components/events/event_modules.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen(this.pet, {super.key});
  final Pet pet;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    // .where((element) => element.petId == pet.id).toList()
    var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
    var dateController = ref.watch(eventDateControllerProvider);
    var nameController = ref.watch(eventNameControllerProvider);
    var descriptionController = ref.watch(eventDescriptionControllerProvider);
    var petEvents = allEvents?.where((element) => element.petId == pet.id);
    var eventsOnSelectedDate = petEvents?.where((event) {
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

    // Creating modules using the provided function
    var modules = createEventModule(context, nameController,
        descriptionController, dateController, ref, allEvents!, pet);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat(
            'MMMM',
            'en_US',
          ).format(dateController),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        toolbarHeight: 33,
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 7)),
              lastDay: DateTime.now().add(const Duration(days: 7)),
              focusedDay: dateController,
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(dateController, day);
              },
              onDaySelected: selectDate,
              locale: 'en_US',
              headerVisible: false,
            ),
          ),
          Text(
            'Events for ${DateFormat('dd/MM/yyyy').format(dateController)}:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 133,
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
                      onPressed: () => deleteEventModule(
                          ref,
                          allEvents,
                          selectDate,
                          dateController,
                          eventsOnSelectedDate![index].id),
                    ),
                  );
                }
              },
            ),
          ),
          EventModules(modules: modules),
        ],
      ),
    );
  }
}
