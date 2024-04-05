import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/new_events/delete_event.dart';
import 'package:pet_diary/src/components/new_events/new_note_event.dart';
import 'package:pet_diary/src/components/new_events/new_temperature_event.dart';
import 'package:pet_diary/src/components/new_events/new_walk_event.dart';
import 'package:pet_diary/src/components/new_events/new_water_event.dart';
import 'package:pet_diary/src/components/new_events/new_weight_event.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';
import 'package:pet_diary/src/screens/pills_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen(this.petId, {super.key});
  final String petId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    List<Event>? allEvents =
        ref.watch(eventRepositoryProvider).value?.getEvents();
    DateTime eventDateTime = ref.watch(eventDateControllerProvider);
    Iterable<Event>? petEvents =
        allEvents?.where((element) => element.petId == widget.petId);
    List<Event>? eventsOnSelectedDate = petEvents?.where((event) {
      return DateFormat('yyyy-MM-dd').format(event.eventDate) ==
          DateFormat('yyyy-MM-dd').format(eventDateTime);
    }).toList();

    void selectDate(DateTime date, DateTime focusedDate) {
      ref.read(eventDateControllerProvider.notifier).state = date;
      eventsOnSelectedDate = allEvents?.where((event) {
        return DateFormat('yyyy-MM-dd').format(event.eventDate) ==
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
          ).format(eventDateTime),
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
              focusedDay: eventDateTime,
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(eventDateTime, day);
              },
              onDaySelected: selectDate,
              locale: 'pl_PL',
              headerVisible: false,
            ),
          ),
          Text(
            'Events for ${DateFormat('dd/MM/yyyy').format(eventDateTime)}:',
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
                var weight = ref
                    .watch(weightRepositoryProvider)
                    .value
                    ?.getWeightById(eventsOnSelectedDate![index].weightId);

                var water = ref
                    .watch(waterRepositoryProvider)
                    .value
                    ?.getWaterById(eventsOnSelectedDate![index].waterId);

                var pill = ref
                    .watch(pillRepositoryProvider)
                    .value
                    ?.getPillById(eventsOnSelectedDate![index].pillId);

                var temperature = ref
                    .watch(temperatureRepositoryProvider)
                    .value
                    ?.getTemperatureById(
                        eventsOnSelectedDate![index].temperatureId);

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
                        if (walk != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Time: ${formatDuration(walk.walkTime.toInt())}'),
                              Text('Kilometers: ${(walk.walkDistance)}'),
                            ],
                          ),
                        if (weight != null)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text('Kilograms: ${weight.weight}')]),
                        if (water != null)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text('Liter: ${water.water}')]),
                        if (temperature != null)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Celcius: ${temperature.temperature}')
                              ]),
                        if (pill != null)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Frequency: ${pill.frequency}'),
                                Text('Dosage: ${pill.dosage}'),
                                Text(
                                    'Start: ${pill.startDate!.day}-${pill.startDate!.month}-${pill.startDate!.year}'),
                                Text(
                                    'End: ${pill.endDate!.day}-${pill.startDate!.month}-${pill.startDate!.year}')
                              ]),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteEvents(ref, allEvents, selectDate,
                          eventsOnSelectedDate![index].id, widget.petId),
                    ),
                  );
                }
              },
            ),
          ),
          Column(
            children: [
              Container(
                color: Colors.grey.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NewWalkEventWidget(
                        iconSize: 60,
                        iconColor: Colors.black,
                        petId: widget.petId,
                        eventDateTime: eventDateTime,
                      ),
                      NewWaterEvent(
                        iconSize: 60,
                        iconColor: Colors.black,
                        petId: widget.petId,
                        eventDateTime: eventDateTime,
                      ),
                      NewTemperatureEvent(
                        iconSize: 60,
                        iconColor: Colors.black,
                        petId: widget.petId,
                        eventDateTime: eventDateTime,
                      ),
                      NewWeightEvent(
                        iconSize: 60,
                        iconColor: Colors.black,
                        petId: widget.petId,
                        eventDateTime: eventDateTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              NewNoteEvent(
                iconSize: 60,
                iconColor: Colors.black,
                petId: widget.petId,
                eventDateTime: eventDateTime,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PillsScreen(widget.petId),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 80,
                    color: Colors.purple,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
