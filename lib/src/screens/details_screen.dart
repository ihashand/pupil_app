import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_icon_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_name_age_button_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_walk_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_water_widget.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/helper/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';
import 'package:pet_diary/src/screens/pet_edit_screen.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final String petId;

  const DetailsScreen({
    super.key,
    required this.petId,
  });

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
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

  @override
  Widget build(BuildContext context) {
    var pet = ref.watch(petRepositoryProvider).value?.getPetById(widget.petId);

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
    Weight? weightEntry = ref
        .watch(weightRepositoryProvider)
        .value
        ?.getWeights()
        .firstWhere((element) => element.petId == widget.petId,
            orElse: () => Weight());

    if (weightEntry != null && weightEntry.weight != 0) {
      weight = '${weightEntry.weight}';
    }

    String walk = '0 km';
    int maxNumberOfBars = 10;

    List<Walk>? walks = ref
        .watch(walkRepositoryProvider)
        .value
        ?.getWalks()
        .where((element) => element.petId == widget.petId)
        .toList();

    List<Walk> lastTenWalks = List<Walk>.empty();

    if (walks != null && walks.isNotEmpty) {
      walks.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      lastTenWalks = walks.take(maxNumberOfBars).toList();
      if (lastTenWalks.isNotEmpty) {
        lastTenWalks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }
      if (lastTenWalks.isNotEmpty) {
        walk = '${lastTenWalks.last.walkDistance} km';
      }
    }

    String water = '0 L';

    List<Water>? waters = ref
        .watch(waterRepositoryProvider)
        .value
        ?.getWater()
        .where((element) => element.petId == widget.petId)
        .toList();

    List<Water> lastTenWaters = List<Water>.empty();

    if (waters != null && waters.isNotEmpty) {
      waters.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      lastTenWaters = waters.take(maxNumberOfBars).toList();
      if (lastTenWaters.isNotEmpty) {
        lastTenWaters.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }
      if (lastTenWaters.isNotEmpty) {
        water = '${lastTenWaters.last.water} L';
      }
    }

    Color buttonColor = Colors.black;
    Color rectangleColor = Colors.black;
    Color diagramFirst = Colors.black;
    Color diagramSecond = Colors.black;
    Color aroundAvatar = Colors.black;
    Color backgroundSectionTwo = Colors.black;
    Color textSecondSectionColor = Colors.black;
    Color appbarButtonsColor = Colors.black;

    if (pet.gender == 'Male') {
      buttonColor = const Color(0xff1d6273).withOpacity(0.8);
      rectangleColor = const Color(0xff68a2b6).withOpacity(0.8);

      diagramFirst = const Color(0xffffcec2);
      diagramSecond = const Color(0xffff8a70);

      aroundAvatar = Theme.of(context).primaryColor.withOpacity(0.8);
      backgroundSectionTwo =
          Theme.of(context).colorScheme.primary.withOpacity(0.8);
      textSecondSectionColor = Colors.black;
      appbarButtonsColor = Colors.black;
    } else if (pet.gender == 'Female') {
      buttonColor = const Color(0xffff8a70);
      rectangleColor = const Color(0xffffcec2);

      diagramFirst = const Color(0xff68a2b6);
      diagramSecond = const Color(0xff1d6273);

      aroundAvatar = Theme.of(context).primaryColor;
      backgroundSectionTwo = Theme.of(context).colorScheme.primary;
      textSecondSectionColor = Colors.black;
      appbarButtonsColor = Colors.black;
    }

    DateTime today = DateTime.now();

    List<Event> todaysEvents = [];

    todaysEvents = ref
            .watch(eventRepositoryProvider)
            .value
            ?.getEvents()
            .where((event) =>
                DateFormat('yyyy-MM-dd').format(event.eventDate) ==
                    DateFormat('yyyy-MM-dd').format(today) &&
                pet.id == event.petId)
            .toList() ??
        [];

    if (todaysEvents.isEmpty) {
      List<Event> allEvents =
          ref.watch(eventRepositoryProvider).value?.getEvents() ?? [];
      allEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));

      for (var event in allEvents) {
        if (event.eventDate.isAfter(today)) {
          todaysEvents.add(event);
          break;
        }
      }
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
                ref.watch(petRepositoryProvider).value?.updatePet(pet);
                ref.invalidate(petRepositoryProvider);
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
                      ref.watch(petRepositoryProvider).value?.updatePet(pet);
                      ref.invalidate(petRepositoryProvider);
                    },
                  ),
                  child: SizedBox(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aroundAvatar,
                        ),
                        child: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 172, 170, 172),
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
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PetDetailNameAgeButtonWidget(
                    pet: pet, buttonColor: buttonColor, petId: widget.petId),
                const SizedBox(
                  height: 10,
                ),
                PetDetailIconWidget(pet: pet, weight: weight),
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
              PetDetailWalkWidget(
                  rectangleColor: buttonColor,
                  textSecondSectionColor: textSecondSectionColor,
                  walk: walk,
                  lastTenWalks: lastTenWalks,
                  diagramFirst: diagramFirst,
                  diagramSecond: diagramSecond),
              const SizedBox(
                width: 10,
              ),
              PetDetailWaterWidget(
                  buttonColor: rectangleColor,
                  textSecondSectionColor: textSecondSectionColor,
                  water: water,
                  lastTenWaters: lastTenWaters,
                  diagramFirst: diagramFirst,
                  diagramSecond: diagramSecond),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          const SizedBox(
            height: 60,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 15.0, 270.0, 15.0),
              child: Text(
                'Events',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
          if (todaysEvents.isNotEmpty)
            Expanded(
              child: ScheduleView(
                events: todaysEvents,
                backgroundColor: rectangleColor,
              ),
            ),
          if (todaysEvents.isEmpty)
            const Center(child: Text('No events for today or in the future')),
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
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(formattedDate,
                  style: const TextStyle(
                    fontSize: 10,
                  )),
              Text(formattedStartTime,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(
            width: 20,
            height: 10,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  if (event.emoticon.isNotEmpty)
                    Text(
                      event.emoticon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(event.description,
                          style: const TextStyle(fontSize: 11)),
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
