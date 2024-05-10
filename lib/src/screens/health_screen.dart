import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/delete_event.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen(this.petId, {super.key});
  final String petId;

  @override
  createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  DateTime defaultDateTime = DateTime.now(); // Domyślna data
  DateTime selectedDateTime = DateTime.now();
  DateTime eventDateTime = DateTime.now();

  bool isCalendarView = true;
  late List<Event> eventsOnSelectedDate;
  late TextEditingController searchController;
  String searchQuery = '';
  bool isUserInteracted = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    eventDateTime = DateTime.now();
    selectedDateTime = DateTime.now();
  }

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
        final List<Event> petEvents =
            allEvents.where((event) => event.petId == widget.petId).toList();
        eventsOnSelectedDate = petEvents
            .where((event) =>
                DateFormat('yyyy-MM-dd').format(event.eventDate) ==
                DateFormat('yyyy-MM-dd').format(eventDateTime))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Health',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: Colors.transparent,
            toolbarHeight: 33,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isCalendarView = !isCalendarView;
                  });
                },
                icon: Icon(
                  isCalendarView ? Icons.grid_view : Icons.calendar_today,
                ),
              ),
            ],
          ),
          body: isCalendarView
              ? _buildCalendarView(eventDateTime, petEvents)
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
                    Expanded(child: _buildTileView()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCalendarView(DateTime eventDateTime, List<Event> petEvents) {
    if (!isUserInteracted) {
      eventDateTime = defaultDateTime;
    }

    // Filtrowanie wydarzeń na podstawie wybranej daty
    final filteredEvents = petEvents
        .where((event) =>
            DateFormat('yyyy-MM-dd').format(event.eventDate) ==
            DateFormat('yyyy-MM-dd').format(eventDateTime))
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
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
                  // Aktualizacja listy wydarzeń po zmianie daty
                  setState(() {});
                },
                onPageChanged: (focusedDate) {
                  setState(() {
                    ref.read(eventDateControllerProvider.notifier).state =
                        focusedDate;
                    eventDateTime = focusedDate;
                    isUserInteracted = true;
                  });
                  // Aktualizacja listy wydarzeń po zmianie daty
                  setState(() {});
                },
                locale: 'en_En',
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xffdfd785),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 118, 188, 245),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(color: Theme.of(context).primaryColorDark),
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
                return _buildEventListItem(event, petEvents);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListItem(Event event, List<Event> petEvents) {
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

  Widget _buildTileView() {
    List<Widget> filteredTiles = _filterTiles().map((tile) {
      return _buildTile(tile.icon, tile.title, tile.color, tile.onTap);
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

  List<_TileInfo> _filterTiles() {
    if (searchQuery.isEmpty) return _allTiles;

    return _allTiles.where((tile) {
      for (String keyword in tile.keywords) {
        if (keyword.toLowerCase().contains(searchQuery)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  Widget _buildTile(
      IconData icon, String title, Color color, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
        left: 7,
        right: 7,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: color.withOpacity(0.6),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileInfo {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> keywords;
  final VoidCallback? onTap;

  _TileInfo(this.icon, this.title, this.color, this.keywords, {this.onTap});
}

final List<_TileInfo> _allTiles = [
  _TileInfo(Icons.directions_walk, 'Activity', Colors.blue,
      ['activity', 'walk', 'wandern', 'fit', 'exercise', 'running'], onTap: () {
    // Add onTap logic for Activity tile
  }),
  _TileInfo(Icons.mood, 'Mood', Colors.amber,
      ['mood', 'emotion', 'feeling', 'happiness', 'sadness', 'joy'], onTap: () {
    // Add onTap logic for Mood tile
  }),
  _TileInfo(Icons.medication, 'Medications', Colors.green, [
    'medication',
    'drugs',
    'pills',
    'therapy',
    'prescription',
    'dosage'
  ], onTap: () {
    // Add onTap logic for Medications tile
  }),
  _TileInfo(Icons.warning, 'Symptoms', Colors.red, [
    'symptom',
    'illness',
    'pain',
    'discomfort',
    'condition',
    'disease'
  ], onTap: () {
    // Add onTap logic for Symptoms tile
  }),
  _TileInfo(Icons.timeline, 'Measurements', Colors.orange, [
    'measurement',
    'data',
    'metrics',
    'record',
    'result',
    'analysis'
  ], onTap: () {
    // Add onTap logic for Measurements tile
  }),
  _TileInfo(Icons.bedtime, 'Sleep', Colors.indigo,
      ['sleep', 'rest', 'nap', 'slumber', 'insomnia', 'bedtime'], onTap: () {
    // Add onTap logic for Sleep tile
  }),
  _TileInfo(Icons.favorite, 'Heart', Colors.pink, [
    'heart',
    'cardio',
    'pulse',
    'blood pressure',
    'rate',
    'exercise'
  ], onTap: () {
    // Add onTap logic for Heart tile
  }),
  _TileInfo(Icons.track_changes, 'Cycle', Colors.teal, [
    'cycle',
    'period',
    'menstruation',
    'ovulation',
    'fertility',
    'reproductive'
  ], onTap: () {
    // Add onTap logic for Cycle tile
  }),
  _TileInfo(Icons.pregnant_woman, 'Pregnancy', Colors.deepOrange, [
    'pregnancy',
    'maternity',
    'expecting',
    'baby',
    'prenatal',
    'parenthood'
  ], onTap: () {
    // Add onTap logic for Pregnancy tile
  }),
  _TileInfo(Icons.dashboard_customize, 'Other Data', Colors.brown, [
    'data',
    'information',
    'records',
    'details',
    'statistics',
    'history'
  ], onTap: () {
    // Add onTap logic for Other Data tile
  }),
];
