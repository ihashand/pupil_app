import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/event_care.dart';
import 'package:pet_diary/src/providers/home_preferences_notifier.dart';
import 'package:pet_diary/src/screens/health_preferences_screen.dart';
import 'package:pet_diary/src/components/events/event_psychic.dart';
import 'package:pet_diary/src/components/events/event_service.dart';
import 'package:pet_diary/src/components/events/event_stomach.dart';
import 'package:pet_diary/src/components/events/event_stool.dart';
import 'package:pet_diary/src/components/events/event_urine.dart';
import 'package:pet_diary/src/components/events/event_vaccine.dart';
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
import 'package:pet_diary/src/widgets/pet_details_widgets/food/event_tile.dart';
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
              _showDetailedAddMenu(context);
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 2,
            ),
            child: _buildAddEventMenu(context, widget.petId, selectedDateTime,
                ref.watch(preferencesProvider)),
          ),
        );
      },
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
      () => buildVaccineSection(context, petId, eventDateTime),
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
        case 'Psychic':
          return sectionBuilders[3]();
        case 'Stool':
          return sectionBuilders[4]();
        case 'Urine':
          return sectionBuilders[5]();
        case 'Mood':
          return sectionBuilders[6]();
        case 'Stomach':
          return sectionBuilders[7]();
        case 'Notes':
          return sectionBuilders[8]();
        case 'Meds':
          return sectionBuilders[9]();
        case 'Vaccine':
          return sectionBuilders[10]();
        default:
          return Container();
      }
    }).toList();

    return GestureDetector(
      onLongPress: () => _showPreferencesDialog(context),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 20, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pick your event',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showPreferencesDialog(context);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColorDark,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xff68a2b6)),
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(10.0),
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
          ],
        ),
      ),
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HealthPreferencesScreen(petId: widget.petId),
      ),
    );
  }

  Widget buildLifestyleSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'L i f e s t y l e',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, bottom: 5),
                child: Column(
                  children: [
                    EventWalk(
                      iconSize: 30,
                      iconColor: Colors.green.withOpacity(0.7),
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                    const SizedBox(height: 10),
                    const Text('Walk', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, bottom: 5),
                child: Column(
                  children: [
                    EventWater(
                      iconSize: 30,
                      iconColor: Colors.blue.withOpacity(0.7),
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                    const SizedBox(height: 10),
                    const Text('Water', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, bottom: 5),
                child: Column(
                  children: [
                    EventTemperature(
                      iconSize: 30,
                      iconColor: Colors.red.withOpacity(0.7),
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                    const SizedBox(height: 10),
                    const Text('Temp', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: Column(
                  children: [
                    EventWeight(
                      iconSize: 30,
                      iconColor: Colors.orange.withOpacity(0.7),
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                    const SizedBox(height: 10),
                    const Text('Weight', style: TextStyle(fontSize: 11)),
                  ],
                ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'G r o o m i n g',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Container(
              width: double.infinity,
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
                      Column(
                        children: [
                          EventCare(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ],
                  ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'S e r v i c e s',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Container(
              width: double.infinity,
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
                      Column(
                        children: [
                          EventService(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                            serviceType: 'Groomer',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          EventService(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                            serviceType: 'Vet',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          EventService(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                            serviceType: 'Training',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          EventService(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                            serviceType: 'Daycare',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          EventService(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                            serviceType: 'Hotel',
                          ),
                        ],
                      ),
                    ],
                  ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'P s y c h i c',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      EventPsychic(
                        iconSize: 50,
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStoolTypeSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'S t o o l',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      EventStool(
                        iconSize: 50,
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUrineColorSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'U r i n e',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      EventUrine(
                        iconSize: 39,
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoodSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'M o o d',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Container(
              width: double.infinity,
              height: 70,
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
                      Column(
                        children: [
                          EventMood(
                            iconSize: 50,
                            petId: petId,
                            eventDateTime: eventDateTime,
                          ),
                        ],
                      ),
                    ],
                  ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'S t o m a c h',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      EventStomach(
                        iconSize: 50,
                        petId: petId,
                        eventDateTime: eventDateTime,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotesSection(
      BuildContext context, String petId, DateTime eventDateTime) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'N o t e s',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  children: [
                    EventNote(
                      iconSize: 50,
                      iconColor: const Color.fromARGB(255, 234, 223, 105),
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

  Widget buildMedsSection(BuildContext context, String petId) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'M e d i c i n e s',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
          Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MedicineScreen(petId),
                ));
              },
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildVaccineSection(
    BuildContext context, String petId, DateTime eventDateTime) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'V a c c i n e',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
        Padding(
          padding:
              const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    EventVaccine(
                      iconSize: 50,
                      petId: petId,
                      eventDateTime: eventDateTime,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
