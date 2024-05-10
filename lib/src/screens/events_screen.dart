import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/delete_event.dart';
import 'package:pet_diary/src/components/events/new_note_event.dart';
import 'package:pet_diary/src/components/events/new_temperature_event.dart';
import 'package:pet_diary/src/components/events/new_walk_event.dart';
import 'package:pet_diary/src/components/events/new_water_event.dart';
import 'package:pet_diary/src/components/events/new_weight_event.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';
import 'package:pet_diary/src/screens/pills_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen(this.petId, {super.key});
  final String petId;

  @override
  createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventStream = ref.watch(eventServiceProvider).getEventsStream();
    final eventDateTime = ref.watch(eventDateControllerProvider);

    return StreamBuilder<List<Event>>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allEvents = snapshot.data ?? [];
        final petEvents =
            allEvents.where((event) => event.petId == widget.petId).toList();
        final eventsOnSelectedDate = petEvents
            .where((event) =>
                DateFormat('yyyy-MM-dd').format(event.eventDate) ==
                DateFormat('yyyy-MM-dd').format(eventDateTime))
            .toList();

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
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (date, focusedDate) {
                    setState(() {
                      selectedDate = date;
                    });
                    ref.read(eventDateControllerProvider.notifier).state = date;
                  },
                  locale: 'pl_PL',
                  headerVisible: false,
                ),
              ),
              Text(
                'Events for ${DateFormat('dd/MM/yyyy').format(selectedDate)}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: eventsOnSelectedDate.length,
                  itemBuilder: (context, index) {
                    final event = eventsOnSelectedDate[index];

                    if (eventsOnSelectedDate.isEmpty) {
                      return const Center(
                        child: Text(
                          "No events on this date",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text(event.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.weightId.isNotEmpty)
                              StreamBuilder<List<Weight?>>(
                                stream: ref
                                    .read(weightServiceProvider)
                                    .getWeightsStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error fetching weights');
                                  }
                                  if (snapshot.hasData) {
                                    final weight = snapshot.data!
                                        .where((element) =>
                                            element!.id == event.weightId)
                                        .firstOrNull;
                                    if (event.id.isEmpty) {
                                      return const Text('');
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Kilograms: ${weight!.weight}'),
                                      ],
                                    );
                                  } else {
                                    return const Text('Loading...');
                                  }
                                },
                              ),
                            if (event.waterId.isNotEmpty)
                              StreamBuilder<List<Water?>>(
                                stream: ref
                                    .read(waterServiceProvider)
                                    .getWatersStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error fetching waters');
                                  }
                                  if (snapshot.hasData) {
                                    final water = snapshot.data!
                                        .where((element) =>
                                            element!.id == event.waterId)
                                        .firstOrNull;
                                    if (water == null) {
                                      return const Text('');
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Liter: ${water.water}'),
                                      ],
                                    );
                                  } else {
                                    return const Text('Loading...');
                                  }
                                },
                              ),
                            if (event.walkId.isNotEmpty)
                              StreamBuilder<List<Walk?>>(
                                stream: ref
                                    .read(walkServiceProvider)
                                    .getWalksStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error fetching walks');
                                  }
                                  if (snapshot.hasData) {
                                    final walk = snapshot.data!
                                        .where((element) =>
                                            element!.id == event.walkId)
                                        .firstOrNull;
                                    if (walk == null) {
                                      return const Text('');
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Time: ${formatDuration(walk.walkTime.toInt())}'),
                                        Text(
                                            'Kilometers: ${walk.walkDistance}'),
                                      ],
                                    );
                                  } else {
                                    return const Text('Loading...');
                                  }
                                },
                              ),
                            if (event.temperatureId.isNotEmpty)
                              StreamBuilder<List<Temperature?>>(
                                stream: ref
                                    .read(temperatureServiceProvider)
                                    .getTemperatureStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                        'Error fetching temperatures');
                                  }
                                  if (snapshot.hasData) {
                                    final temperature = snapshot.data!
                                        .where((element) =>
                                            element!.id == event.temperatureId)
                                        .firstOrNull;
                                    if (temperature == null) {
                                      return const Text('No temperatures');
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Celcius: ${temperature.temperature}'),
                                      ],
                                    );
                                  } else {
                                    return const Text('Loading...');
                                  }
                                },
                              ),
                            if (event.pillId.isNotEmpty)
                              StreamBuilder<List<Pill?>>(
                                stream:
                                    ref.read(pillServiceProvider).getPills(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error fetching pills');
                                  }
                                  if (snapshot.hasData) {
                                    final pill = snapshot.data!
                                        .where((element) =>
                                            element!.id == event.pillId)
                                        .firstOrNull;
                                    if (pill == null) {
                                      return const Text('');
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Frequency: ${pill.frequency}'),
                                        Text('Dosage: ${pill.dosage}'),
                                        Text(
                                          'Start: ${DateFormat('dd-MM-yyyy').format(pill.startDate!)}',
                                        ),
                                        Text(
                                          'End: ${DateFormat('dd-MM-yyyy').format(pill.endDate!)}',
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Text('Loading...');
                                  }
                                },
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              deleteEvents(ref, context, allEvents, event.id),
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
      },
    );
  }

  String formatDuration(int durationInMinutes) {
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;
    final formattedDuration = '$hours:${minutes.toString().padLeft(2, '0')}';
    return formattedDuration;
  }

  void selectDate(DateTime date, DateTime focusedDate) {
    setState(() {
      selectedDate = date;
    });
    ref.read(eventDateControllerProvider.notifier).state = date;
  }
}
