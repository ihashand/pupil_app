import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/health/event_list_item_builder.dart';
import 'package:pet_diary/src/components/health/get_all_tiles.dart';
import 'package:pet_diary/src/components/health/health_tile.dart';
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
                ),
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
                    Expanded(child: buildHealthTileView(context)),
                  ],
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
                  setState(() {});
                },
                onPageChanged: (focusedDate) {
                  setState(() {
                    ref.read(eventDateControllerProvider.notifier).state =
                        focusedDate;
                    eventDateTime = focusedDate;
                    isUserInteracted = true;
                  });
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
                return EventListItemBuilder(
                    ref: ref,
                    context: context,
                    event: event,
                    petEvents: petEvents);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHealthTileView(BuildContext context) {
    List<Widget> filteredTiles =
        _filterTiles(context, widget.petId).map((tile) {
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

  List<TileInfoModel> _filterTiles(BuildContext context, String petId) {
    if (searchQuery.isEmpty) {
      return getAllTiles(context, petId);
    }

    return getAllTiles(context, petId).where((tile) {
      for (String keyword in tile.keywords) {
        if (keyword.toLowerCase().contains(searchQuery)) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}
