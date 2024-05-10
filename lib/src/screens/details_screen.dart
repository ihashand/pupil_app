import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_icon_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_name_age_button_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_walk_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_water_widget.dart';
import 'package:pet_diary/src/data/services/pet_services.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/helper/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';
import 'package:pet_diary/src/screens/events_screen.dart';
import 'package:pet_diary/src/screens/pet_edit_screen.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final String petId;

  const DetailsScreen({
    super.key,
    required this.petId,
  });

  @override
  createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  DateTime? findNextEventDate(List<Event> events) {
    DateTime today = DateTime.now();
    DateTime? nextEventDate;

    for (var event in events) {
      if (event.eventDate.isAfter(today)) {
        if (nextEventDate == null || event.eventDate.isBefore(nextEventDate)) {
          nextEventDate = event.eventDate;
        }
      }
    }

    return nextEventDate;
  }

  Pet? _pet;

  @override
  void initState() {
    super.initState();

    final petService = ref.read(petServiceProvider);

    _fetchPet(petService);
  }

  Future<void> _fetchPet(PetService petService) async {
    final fetchedPet = await petService.getPetById(widget.petId);
    setState(() {
      _pet = fetchedPet;
    });
  }

  @override
  Widget build(BuildContext context) {
    var pet = _pet;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.more_horiz),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('Pet not found')),
      );
    }

    String weight = '';

    StreamBuilder<List<Weight?>>(
      stream: ref.read(weightServiceProvider).getWeightsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error fetching weights');
        }
        if (snapshot.hasData) {
          weight = snapshot.data!
              .firstWhere((element) => element!.petId == widget.petId)!
              .weight
              .toString();
        }
        return const Text('');
      },
    );

    String walk = '0 km';
    int maxNumberOfBars = 10;

    String water = '0 L';

    Color buttonColor = Colors.black;
    Color healthButtonColor = Colors.black;
    Color eventTileBackgroundColor = Colors.black;

    Color rectangleColor = Colors.black;
    Color diagramFirst = Colors.black;
    Color diagramSecond = Colors.black;
    Color backgroundSectionTwo = Colors.black;
    Color textSecondSectionColor = Colors.black;
    Color appbarButtonsColor = Colors.black;
    Color avatarBackgroundColor = Colors.black;

    if (pet.gender == 'Male') {
      // Colors specific to Male pets
      buttonColor = const Color(0xff68a2b6);
      healthButtonColor = const Color(0xffdfd785);
      eventTileBackgroundColor = const Color(0xffdfd785).withOpacity(0.7);
      rectangleColor = const Color(0xffb3e1f9);
      diagramFirst = const Color(0xffdfd785);
      diagramSecond = const Color(0xffeb9e5c);
      avatarBackgroundColor =
          const Color.fromARGB(255, 90, 182, 232).withOpacity(0.2);

      // Theme-based adjustments for Male pets
      backgroundSectionTwo =
          Theme.of(context).colorScheme.primary.withOpacity(0.8);

      // Common text and buttons colors for both genders
      textSecondSectionColor = Colors.black;
      appbarButtonsColor = Colors.black;
    } else if (pet.gender == 'Female') {
      // Colors specific to Female pets
      buttonColor = const Color(0xffff8a70);
      healthButtonColor = const Color(0xffdfd785);
      eventTileBackgroundColor = Theme.of(context).colorScheme.primary;

      rectangleColor = const Color(0xffffcec2);
      diagramFirst = const Color(0xffffd15c);
      diagramSecond = const Color(0xffeb9e5c);
      avatarBackgroundColor = const Color(0xffffcec2).withOpacity(0.2);

      // Theme-based adjustments for Female pets

      backgroundSectionTwo = Theme.of(context).colorScheme.primary;

      // Common text and buttons colors for both genders
      textSecondSectionColor = Colors.black;
      appbarButtonsColor = Colors.black;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appbarButtonsColor),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              iconSize: 35,
              color: textSecondSectionColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PetEditScreen(petId: pet.id)),
                );
              },
            ),
          ),
        ],
        flexibleSpace: GestureDetector(
          onLongPress: () {
            showBackgroundSelectionDialog(
              context: context,
              onBackgroundSelected: (String path) {
                setState(() {
                  pet.backgroundImage = path;
                });
                ref.watch(petServiceProvider).updatePet(pet);
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ExactAssetImage(pet.backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                GestureDetector(
                  onTap: () => showAvatarSelectionDialog(
                    context: context,
                    onAvatarSelected: (String path) {
                      setState(() {
                        pet.avatarImage = path;
                      });
                      ref.watch(petServiceProvider).updatePet(pet);
                    },
                  ),
                  child: SizedBox(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          backgroundColor: avatarBackgroundColor,
                          backgroundImage: pet.avatarImage.isNotEmpty
                              ? AssetImage(pet.avatarImage)
                              : null,
                          radius: 85,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0),
          child: Container(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: backgroundSectionTwo,
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PetDetailNameAgeButtonWidget(
                    buttonColor: healthButtonColor, petId: widget.petId),
                const SizedBox(
                  height: 10,
                ),
                PetDetailIconWidget(petId: pet.id, weight: weight),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: StreamBuilder<List<Walk?>>(
                  stream: ref.read(walkServiceProvider).getWalksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error fetching walks: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.active ||
                        snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        List<Walk?> walks = snapshot.data!
                            .where((walk) => walk!.petId == widget.petId)
                            .toList();

                        List<Walk?> lastTenWalks = [];

                        if (walks.isNotEmpty) {
                          walks.sort(
                              (a, b) => b!.dateTime.compareTo(a!.dateTime));
                          lastTenWalks = walks.take(maxNumberOfBars).toList();
                          if (lastTenWalks.isNotEmpty) {
                            lastTenWalks.sort(
                                (a, b) => a!.dateTime.compareTo(b!.dateTime));
                          }
                          if (lastTenWalks.isNotEmpty) {
                            walk = '${lastTenWalks.last!.walkDistance} km';
                          }
                        }
                        return PetDetailWalkWidget(
                            rectangleColor: buttonColor,
                            textSecondSectionColor: textSecondSectionColor,
                            walk: walk,
                            lastTenWalks: lastTenWalks,
                            diagramFirst: diagramFirst,
                            diagramSecond: diagramSecond);
                      } else {
                        return PetDetailWalkWidget(
                            rectangleColor: buttonColor,
                            textSecondSectionColor: textSecondSectionColor,
                            walk: walk,
                            lastTenWalks: const [],
                            diagramFirst: diagramFirst,
                            diagramSecond: diagramSecond);
                      }
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: StreamBuilder<List<Water?>>(
                  stream: ref.read(waterServiceProvider).getWatersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error fetching walks: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.active ||
                        snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        List<Water?> waters = snapshot.data!
                            .where((water) => water!.petId == widget.petId)
                            .toList();

                        List<Water?> lastTenWaters = List<Water>.empty();

                        if (snapshot.hasData) {
                          waters = snapshot.data!
                              .where(
                                  (element) => element!.petId == widget.petId)
                              .toList();

                          if (waters.isNotEmpty) {
                            waters.sort(
                                (a, b) => b!.dateTime.compareTo(a!.dateTime));
                            lastTenWaters =
                                waters.take(maxNumberOfBars).toList();
                            if (lastTenWaters.isNotEmpty) {
                              lastTenWaters.sort(
                                  (a, b) => a!.dateTime.compareTo(b!.dateTime));
                            }
                            if (lastTenWaters.isNotEmpty) {
                              water = '${lastTenWaters.last!.water} L';
                            }
                          }
                        }
                        return PetDetailWaterWidget(
                            buttonColor: rectangleColor,
                            textSecondSectionColor: textSecondSectionColor,
                            water: water,
                            lastTenWaters: lastTenWaters,
                            diagramFirst: diagramFirst,
                            diagramSecond: diagramSecond);
                      } else {
                        return PetDetailWaterWidget(
                            buttonColor: rectangleColor,
                            textSecondSectionColor: textSecondSectionColor,
                            water: water,
                            lastTenWaters: const [],
                            diagramFirst: diagramFirst,
                            diagramSecond: diagramSecond);
                      }
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Events',
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColorDark),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventsScreen(widget.petId),
                      ),
                    );
                  },
                  child: Text(
                    'Add new',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<Event>>(
            stream: ref.watch(eventServiceProvider).getEventsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error fetching pets');
              }
              if (snapshot.hasData) {
                final events = snapshot.data!
                    .where((element) => element.petId == widget.petId)
                    .toList();

                List<Event> eventsToShow = [];
                DateTime today = DateTime.now();
                DateTime? nextEventDate;

                for (var event in events) {
                  if (event.eventDate.year == today.year &&
                      event.eventDate.month == today.month &&
                      event.eventDate.day == today.day) {
                    eventsToShow.add(event);
                  } else if (event.eventDate.isAfter(today)) {
                    if (nextEventDate == null ||
                        event.eventDate.isBefore(nextEventDate)) {
                      nextEventDate = event.eventDate;
                    }
                  }
                }

                if (eventsToShow.isEmpty && nextEventDate != null) {
                  eventsToShow = events
                      .where((event) =>
                          event.eventDate.year == nextEventDate!.year &&
                          event.eventDate.month == nextEventDate.month &&
                          event.eventDate.day == nextEventDate.day)
                      .toList();
                }

                if (eventsToShow.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'No events for today or in the future',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 30),
                        Icon(
                          Icons.sentiment_dissatisfied,
                          size: 100,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: eventsToShow.length,
                    itemBuilder: (context, index) {
                      if (events.isEmpty) {
                        return const Text(
                          'No events for today or in the future',
                        );
                      } else {
                        final currentEvent = eventsToShow[index];
                        return SizedBox(
                          height: 87,
                          width: 180,
                          child: EventTile(
                            event: currentEvent,
                            backgroundColor: eventTileBackgroundColor,
                          ),
                        );
                      }
                    },
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

class EventTile extends StatelessWidget {
  final Event event;
  final Color backgroundColor;

  const EventTile(
      {super.key, required this.event, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    String formattedStartTime = DateFormat('HH:mm').format(event.eventDate);
    String formattedDate = DateFormat('d MMM').format(event.eventDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(formattedDate, style: const TextStyle(fontSize: 10)),
              Text(formattedStartTime,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(
                  height: 10), // Zwiększono odstęp między datą a emotikonem
            ],
          ),
          const SizedBox(
              width: 20), // Zwiększono odstęp między datą a emotikonem
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.emoticon.isNotEmpty)
                        Text(event.emoticon,
                            style: const TextStyle(fontSize: 30)),
                      const SizedBox(
                          width:
                              20), // Zwiększono odstęp między emotikonem a nazwą
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(
                              height:
                                  4), // Zwiększono odstęp między nazwą a opisem
                          Text(event.description,
                              style: const TextStyle(fontSize: 10)),
                        ],
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
}

class ScheduleView extends StatelessWidget {
  final List<Event> events;
  final Color backgroundColor;

  const ScheduleView(
      {super.key, required this.events, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventTile(
          event: events[index],
          backgroundColor: backgroundColor,
        );
      },
    );
  }
}
