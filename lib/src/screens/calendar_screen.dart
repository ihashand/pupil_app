import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/event_modules/create_event_module.dart';
import 'package:pet_diary/src/components/events/add_delete_event/delete_event_module.dart';
import 'package:pet_diary/src/components/events/event_modules/event_modules.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen(this.petId, {super.key});
  final String petId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    // Pobierz wszystkie wydarzenia
    var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
    var dateController = ref.watch(eventDateControllerProvider);
    var nameController = ref.watch(eventNameControllerProvider);
    var descriptionController = ref.watch(eventDescriptionControllerProvider);
    // Filtruj wydarzenia dla zwierzaka o danym petId
    var petEvents = allEvents?.where((element) => element.petId == petId);
    // Pobierz wydarzenia dla wybranej daty
    var eventsOnSelectedDate = petEvents?.where((event) {
      return DateFormat('yyyy-MM-dd').format(event.date) ==
          DateFormat('yyyy-MM-dd').format(dateController);
    }).toList();

    void selectDate(DateTime date, DateTime focusedDate) {
      ref.read(eventDateControllerProvider.notifier).state = date;
      // Zaktualizuj wydarzenia dla wybranej daty
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
            height: 200,
            child: ListView.builder(
              itemCount: eventsOnSelectedDate?.length ?? 0,
              itemBuilder: (context, index) {
                var walk = ref
                    .watch(walkRepositoryProvider)
                    .value
                    ?.getWalkById(eventsOnSelectedDate![index].walkId);

                // Sprawdź, czy lista wydarzeń dla wybranej daty jest pusta
                if (eventsOnSelectedDate == null ||
                    eventsOnSelectedDate!.isEmpty) {
                  return const ListTile(
                    title: Text("No events on this date"),
                  );
                } else {
                  // Wyświetl szczegóły wydarzenia
                  return ListTile(
                    title: Text(eventsOnSelectedDate![index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eventsOnSelectedDate![index].walkId.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Time: ${formatDuration(walk!.walkTime.toInt())}'),
                              Text('Distance: ${(walk.walkDistance)}'),
                            ],
                          ),
                        // Warunkowo wyświetlaj inne szczegóły w zależności od dostępności danych
                        if (eventsOnSelectedDate![index].durationTime == 0)
                          if (eventsOnSelectedDate![index].value == 0)
                            // Wyświetl opis wydarzenia, jeśli dostępny
                            Text(eventsOnSelectedDate![index].description)
                          else
                            // Wyświetl wartość, jeśli dostępna
                            Text(
                              '${(eventsOnSelectedDate![index].value)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                        else
                          // Wyświetl czas trwania wydarzenia, jeśli dostępny
                          Text(
                            ' ${formatDuration(eventsOnSelectedDate![index].durationTime)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteEventModule(
                          ref,
                          allEvents,
                          selectDate,
                          dateController,
                          eventsOnSelectedDate![index].id,
                          petId),
                    ),
                  );
                }
              },
            ),
          ),
          // Dodaj moduł tworzenia nowego wydarzenia
          EventModules(
              modules: createEventModule(
            context,
            nameController,
            descriptionController,
            dateController,
            ref,
            allEvents,
            petId,
          )),
        ],
      ),
    );
  }
}
