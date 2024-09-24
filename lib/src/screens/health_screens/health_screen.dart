import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/screens/events_screens/event_type_selection_screen.dart';
import 'package:pet_diary/src/providers/others_providers/home_preferences_notifier.dart';
import 'package:pet_diary/src/components/health/get_all_tiles.dart';
import 'package:pet_diary/src/components/health/health_tile.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/others/tile_info.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_tile.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref.read(homePreferencesProvider.notifier).setUserId(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventDateTime = ref.watch(eventDateControllerProvider);
    final asyncEvents = ref.watch(eventsProvider(widget.petId));

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
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: Theme.of(context).primaryColorDark, size: 20),
            title: Text(
              'H E A L T H',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).primaryColorDark,
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
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: _buildSwitch(context),
            ),
          ),
          body: isCalendarView
              ? _buildCalendarView(
                  context, eventDateTime, petEvents, widget.petId)
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )),
                        child: Column(
                          children: [
                            Divider(
                                color: Colors.blueGrey.shade100, height: 20),
                            TextField(
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: buildHealthTileView(context, petEvents)),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff68a2b6),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EventTypeSelectionScreen(petId: widget.petId),
                ),
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

  Widget _buildSwitch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Calendar', 'List'].map((label) {
          String displayLabel = label;
          Color bgColor = Colors.transparent;
          if ((isCalendarView && label == 'Calendar') ||
              (!isCalendarView && label == 'List')) {
            displayLabel = label;
            bgColor = const Color(0xff68a2b6).withOpacity(0.2);
          }
          return TextButton(
            onPressed: () {
              setState(() {
                isCalendarView = (label == 'Calendar');
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              displayLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCalendarView == (label == 'Calendar')
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, DateTime eventDateTime,
      List<Event> petEvents, String petId) {
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
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  Divider(color: Colors.blueGrey.shade100, height: 20),
                  TableCalendar(
                    locale: 'en_US',
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2050, 3, 14),
                    focusedDay: selectedDateTime,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDateTime, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        selectedDateTime = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                            DateTime.now().hour,
                            DateTime.now().minute);

                        ref.read(eventDateControllerProvider.notifier).state =
                            selectedDay;
                        isUserInteracted = true;
                      });
                    },
                    eventLoader: (day) {
                      return petEvents
                          .where((event) => isSameDay(event.eventDate, day))
                          .toList();
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return _buildEventsMarker(date, events);
                        }
                        return null;
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).primaryColorDark,
                        size: 24,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).primaryColorDark,
                        size: 24,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Color(0xff68a2b6),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xffdfd785),
                        shape: BoxShape.circle,
                      ),
                    ),
                    daysOfWeekVisible: false,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                  ),
                ],
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
                  child: EventTile(
                    ref: ref,
                    event: event,
                    isExpanded: expandedEvents[event.id] ?? false,
                    petId: petId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        width: 5.0,
        height: 5.0,
        margin: const EdgeInsets.only(top: 7, right: 7),
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
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: filteredTiles.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: filteredTiles,
              )
            : Column(
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    'No matching records found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Icon(Icons.sentiment_dissatisfied,
                      size: 200,
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.1)),
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
}
