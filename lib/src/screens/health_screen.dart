import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/health/get_all_tiles.dart';
import 'package:pet_diary/src/components/health/health_tile.dart';
import 'package:pet_diary/src/components/events/new_note_event.dart';
import 'package:pet_diary/src/components/events/new_temperature_event.dart';
import 'package:pet_diary/src/components/events/new_walk_event.dart';
import 'package:pet_diary/src/components/events/new_water_event.dart';
import 'package:pet_diary/src/components/events/new_weight_event.dart';
import 'package:pet_diary/src/screens/medicine_screen.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/tile_info.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen(this.petId, {super.key});
  final String petId;

  @override
  createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  DateTime defaultDateTime = DateTime.now();
  DateTime selectedDateTime = DateTime.now();
  DateTime eventDateTime = DateTime.now();

  bool isCalendarView = true;
  late List<Event> eventsOnSelectedDate;
  late TextEditingController searchController;
  String searchQuery = '';
  bool isUserInteracted = false;

  Map<String, bool> expandedEvents = {};

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    eventDateTime = DateTime.now();
    selectedDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final eventDateTime = ref.watch(eventDateControllerProvider);
    final asyncEvents = ref.watch(eventsProvider);

    return asyncEvents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (allEvents) {
        final List<Event> petEvents =
            allEvents.where((event) => event.petId == widget.petId).toList();
        eventsOnSelectedDate = petEvents
            .where((event) =>
                DateFormat('yyyy-MM-dd').format(event.eventDate) ==
                DateFormat('yyyy-MM-dd').format(eventDateTime))
            .toList();

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
            title: Text(
              'H e a l t h',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            toolbarHeight: 50,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isCalendarView = !isCalendarView;
                  });
                },
                icon: Icon(
                    isCalendarView ? Icons.grid_view : Icons.calendar_today,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
              ),
            ],
          ),
          body: isCalendarView
              ? _buildCalendarView(context, eventDateTime, petEvents)
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, top: 40, bottom: 10),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: buildHealthTileView(context, petEvents)),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff68a2b6),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2,
                      ),
                      child: _buildAddEventMenu(
                          context, widget.petId, eventDateTime),
                    ),
                  );
                },
              );
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(
      BuildContext context, DateTime eventDateTime, List<Event> petEvents) {
    if (!isUserInteracted) {
      eventDateTime = defaultDateTime;
    }

    final filteredEvents = petEvents
        .where((event) =>
            DateFormat('yyyy-MM-dd').format(event.eventDate) ==
            DateFormat('yyyy-MM-dd').format(eventDateTime))
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: eventDateTime,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDateTime, day);
                },
                onDaySelected: (date, focusedDate) {
                  setState(() {
                    selectedDateTime = date;
                    ref.read(eventDateControllerProvider.notifier).state = date;
                    isUserInteracted = true;
                  });
                },
                onPageChanged: (focusedDate) {
                  setState(() {
                    ref.read(eventDateControllerProvider.notifier).state =
                        focusedDate;
                    eventDateTime = focusedDate;
                    isUserInteracted = true;
                  });
                },
                locale: 'en_En',
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xffdfd785),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xff68a2b6),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                      fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left,
                      color: Theme.of(context).primaryColorDark),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: Theme.of(context).primaryColorDark),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedEvents[event.id] =
                          !(expandedEvents[event.id] ?? false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          event.emoticon,
                          style: const TextStyle(fontSize: 30),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.6),
                                ),
                              ),
                              if (expandedEvents[event.id] ?? false) ...[
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  event.description,
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy')
                                      .format(event.eventDate),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5)),
                          onPressed: () =>
                              _showDeleteConfirmation(context, event),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHealthTileView(BuildContext context, List<Event> petEvents) {
    List<Widget> filteredTiles =
        _filterTiles(context, widget.petId, petEvents).map((tile) {
      return HealthTile(
          icon: tile.icon,
          title: tile.title,
          color: tile.color,
          onTap: tile.onTap,
          context: context);
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: filteredTiles.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: filteredTiles,
              )
            : Column(
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    'No matching records found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Icon(Icons.sentiment_dissatisfied,
                      size: 80, color: Theme.of(context).primaryColorDark),
                ],
              ),
      ),
    );
  }

  List<TileInfoModel> _filterTiles(
      BuildContext context, String petId, List<Event> petEvents) {
    if (searchQuery.isEmpty) {
      return getAllTiles(context, petId, petEvents);
    }

    return getAllTiles(context, petId, petEvents).where((tile) {
      for (String keyword in tile.keywords) {
        if (keyword.toLowerCase().contains(searchQuery)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  Widget _buildAddEventMenu(
      BuildContext context, String petId, DateTime eventDateTime) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Lifestyle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NewWalkEventWidget(
                        iconSize: 50,
                        iconColor: Colors.green.withOpacity(0.5),
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                      NewWaterEvent(
                        iconSize: 50,
                        iconColor: Colors.blue.withOpacity(0.5),
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                      NewTemperatureEvent(
                        iconSize: 50,
                        iconColor: Colors.red.withOpacity(0.5),
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                      NewWeightEvent(
                        iconSize: 50,
                        iconColor: Colors.orange.withOpacity(0.5),
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: NewNoteEvent(
                        iconSize: 50,
                        iconColor: const Color.fromARGB(255, 234, 223, 105)
                            .withOpacity(0.5),
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Meds',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MedicineScreen(petId),
                      ));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.medication,
                          size: 50,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
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
                ref.read(eventServiceProvider).deleteEvent(event.id);
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
}
