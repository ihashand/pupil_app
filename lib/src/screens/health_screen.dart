import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/delete_event.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen(this.petId, {Key? key}) : super(key: key);
  final String petId;

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  DateTime selectedDate = DateTime.now();
  bool isCalendarView = true;
  var eventsOnSelectedDate;
  late TextEditingController searchController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
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
        final petEvents =
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
                          right: 20, left: 20, top: 20, bottom: 10),
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
                    Expanded(child: _buildTileView()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCalendarView(DateTime eventDateTime, List<Event> petEvents) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 10),
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: eventDateTime,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) {
            return isSameDay(selectedDate, day);
          },
          onDaySelected: (date, focusedDate) {
            setState(() {
              selectedDate = date;
              ref.read(eventDateControllerProvider.notifier).state = date;
            });
          },
          onPageChanged: (focusedDate) {
            setState(() {
              ref.read(eventDateControllerProvider.notifier).state =
                  focusedDate;
            });
          },
          locale: 'en_En',
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xffdfd785),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(color: Colors.black),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          ),
        ),
        SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: eventsOnSelectedDate.length,
            itemBuilder: (context, index) {
              final event = eventsOnSelectedDate[index];
              return _buildEventListItem(event, petEvents);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventListItem(Event event, List<Event> petEvents) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: Text(event.title),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deleteEvents(ref, petEvents, event.id),
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
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
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
                size: 48,
                color: color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
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
