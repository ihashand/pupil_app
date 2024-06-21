import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/event_care.dart';
import 'package:pet_diary/src/components/events/event_delete_func.dart';
import 'package:pet_diary/src/components/events/event_preferences_dialog.dart';
import 'package:pet_diary/src/components/events/event_psychic.dart';
import 'package:pet_diary/src/components/events/event_service.dart';
import 'package:pet_diary/src/components/events/event_stomach.dart';
import 'package:pet_diary/src/components/events/event_stool.dart';
import 'package:pet_diary/src/components/events/event_urine.dart';
import 'package:pet_diary/src/components/health/get_all_tiles.dart';
import 'package:pet_diary/src/components/health/health_tile.dart';
import 'package:pet_diary/src/components/events/event_note.dart';
import 'package:pet_diary/src/components/events/event_temperature.dart';
import 'package:pet_diary/src/components/events/event_walk.dart';
import 'package:pet_diary/src/components/events/event_water.dart';
import 'package:pet_diary/src/components/events/event_weight.dart';
import 'package:pet_diary/src/components/events/event_mood.dart';
import 'package:pet_diary/src/models/event_preferences.dart';
import 'package:pet_diary/src/providers/event_preferences_provider.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref
          .read(preferencesProvider.notifier)
          .setUserIdAndPetId(user.uid, widget.petId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventDateTime = ref.watch(eventDateControllerProvider);
    final asyncEvents = ref.watch(eventsProvider);
    final preferences = ref.watch(preferencesProvider);

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
              ? _buildCalendarView(context, eventDateTime, petEvents)
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
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2,
                      ),
                      child: _buildAddEventMenu(
                          context, widget.petId, eventDateTime, preferences),
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
            bgColor = const Color(0xff68a2b6)
                .withOpacity(0.2); // Niebieskie tło dla wybranego przycisku
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
                    ? Theme.of(context)
                        .primaryColorDark // Biały tekst dla wybranego przycisku
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
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
                        selectedDateTime = selectedDay;
                        ref.read(eventDateControllerProvider.notifier).state =
                            selectedDay;
                        isUserInteracted = true;
                      });
                    },
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
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Text(
                          event.emoticon,
                          style: const TextStyle(fontSize: 30),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              if (expandedEvents[event.id] ?? false) ...[
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  event.description,
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy')
                                      .format(event.eventDate),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context).primaryColorDark),
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

  Widget _buildAddEventMenu(BuildContext context, String petId,
      DateTime eventDateTime, PreferencesModel preferences) {
    List<Widget Function()> sectionBuilders = [
      () => buildLifestyleSection(context, petId, eventDateTime),
      () => buildCareSection(context, petId, eventDateTime),
      () => buildServicesSection(context, petId, eventDateTime),
      () => buildPsychicIssuesSection(context, petId, eventDateTime),
      () => buildStoolTypeSection(context, petId, eventDateTime),
      () => buildUrineColorSection(context, petId, eventDateTime),
      () => buildMoodSection(context, petId, eventDateTime),
      () => buildStomachIssuesSection(context, petId, eventDateTime),
      () => buildNotesSection(context, petId, eventDateTime),
      () => buildMedsSection(context, petId),
    ];

    List<Widget> visibleSections = preferences.sectionOrder
        .where((section) => preferences.visibleSections.contains(section))
        .map((section) {
      switch (section) {
        case 'Lifestyle':
          return sectionBuilders[0]();
        case 'Care':
          return sectionBuilders[1]();
        case 'Services':
          return sectionBuilders[2]();
        case 'Psychic Issues':
          return sectionBuilders[3]();
        case 'Stool Type':
          return sectionBuilders[4]();
        case 'Urine Color':
          return sectionBuilders[5]();
        case 'Mood':
          return sectionBuilders[6]();
        case 'Stomach Issues':
          return sectionBuilders[7]();
        case 'Notes':
          return sectionBuilders[8]();
        case 'Meds':
          return sectionBuilders[9]();
        default:
          return Container();
      }
    }).toList();

    return GestureDetector(
      onLongPress: () => _showPreferencesDialog(context),
      child: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(20.0),
          child: visibleSections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'No sections available to display.',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Long press to configure preferences.',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                )
              : Column(
                  children: visibleSections
                      .expand((section) => [
                            Row(
                              children: [
                                Expanded(child: section),
                              ],
                            ),
                            const SizedBox(height: 8)
                          ])
                      .toList(),
                ),
        ),
      ),
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PreferencesDialog(petId: widget.petId);
      },
    );
  }

  Widget buildLifestyleSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Lifestyle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EventWalk(
                iconSize: 40,
                iconColor: Colors.green.withOpacity(0.7),
                petId: petId,
                eventDateTime: eventDateTime,
              ),
              EventWater(
                iconSize: 40,
                iconColor: Colors.blue.withOpacity(0.7),
                petId: petId,
                eventDateTime: eventDateTime,
              ),
              EventTemperature(
                iconSize: 40,
                iconColor: Colors.red.withOpacity(0.7),
                petId: petId,
                eventDateTime: eventDateTime,
              ),
              EventWeight(
                iconSize: 40,
                iconColor: Colors.orange.withOpacity(0.7),
                petId: petId,
                eventDateTime: eventDateTime,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCareSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Care',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    EventCare(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServicesSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Services',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    EventService(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                      serviceType: 'Groomer',
                    ),
                    EventService(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                      serviceType: 'Vet',
                    ),
                    EventService(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                      serviceType: 'Training',
                    ),
                    EventService(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                      serviceType: 'Daycare',
                    ),
                    EventService(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                      serviceType: 'Hotel',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPsychicIssuesSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Psychic Issues',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EventPsychic(
                  iconSize: 50,
                  petId: petId,
                  eventDateTime: eventDateTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStoolTypeSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Stool Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EventStool(
                  iconSize: 50,
                  petId: petId,
                  eventDateTime: eventDateTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUrineColorSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Urine Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EventUrine(
                  iconSize: 39,
                  petId: petId,
                  eventDateTime: eventDateTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoodSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Mood',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    EventMood(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStomachIssuesSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Stomach Issues',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EventStomach(
                  iconSize: 50,
                  petId: petId,
                  eventDateTime: eventDateTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotesSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
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
              child: EventNote(
                iconSize: 50,
                iconColor: const Color.fromARGB(255, 234, 223, 105),
                petId: petId,
                eventDateTime: eventDateTime,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMedsSection(BuildContext context, String petId) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Meds',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
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
              child: const Center(
                child: Icon(
                  Icons.medication,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
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
                var allEvents = [event];
                eventDeleteFunc(ref, context, allEvents, event.id);
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
