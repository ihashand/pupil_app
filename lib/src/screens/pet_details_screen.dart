import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_icon_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_name_age_button_widget.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/services/pet_services.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/helper/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';
import 'package:pet_diary/src/screens/pet_edit_screen.dart';

class PetDetailsScreen extends ConsumerStatefulWidget {
  final String petId;

  const PetDetailsScreen({
    super.key,
    required this.petId,
  });

  @override
  createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends ConsumerState<PetDetailsScreen> {
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

    Color healthButtonColor = const Color(0xffdfd785);
    Color eventTileBackgroundColor =
        Theme.of(context).colorScheme.primary.withOpacity(0.7);
    Color backgroundSectionTwo =
        Theme.of(context).colorScheme.primary.withOpacity(0.8);
    Color textSecondSectionColor = Colors.black;
    Color appbarButtonsColor = Colors.black;
    Color avatarBackgroundColor =
        const Color.fromARGB(255, 90, 182, 232).withOpacity(0.2);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appbarButtonsColor.withOpacity(0.7)),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              iconSize: 35,
              color: textSecondSectionColor.withOpacity(0.7),
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
                  height: 45,
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
                        padding: const EdgeInsets.all(5),
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
          preferredSize: const Size.fromHeight(130.0),
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
                const SizedBox(height: 10),
                Consumer(builder: (context, ref, _) {
                  final asyncWeights = ref.watch(weightsProvider);
                  return asyncWeights.when(
                    loading: () => const Text('Loading...'),
                    error: (err, stack) => const Text('Error fetching weights'),
                    data: (weights) {
                      var weight = weights
                          .firstWhere(
                              (element) => element!.petId == widget.petId,
                              orElse: () => Weight(
                                    id: '',
                                    weight: 0.0,
                                    eventId: '',
                                    petId: widget.petId,
                                    dateTime: DateTime.now(),
                                  ))!
                          .weight;

                      return PetDetailIconWidget(
                          petId: pet.id, weight: weight.toString());
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'E v e n t s',
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer(builder: (context, ref, _) {
            final asyncEvents = ref.watch(eventsProvider);
            return asyncEvents.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Error fetching events'),
              data: (events) {
                final petEvents = events
                    .where((element) => element.petId == widget.petId)
                    .toList();

                List<Event> eventsToShow = [];
                DateTime today = DateTime.now();
                DateTime? nextEventDate;

                for (var event in petEvents) {
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
                  eventsToShow = petEvents
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
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: eventsToShow.length,
                    itemBuilder: (context, index) {
                      if (eventsToShow.isEmpty) {
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
              },
            );
          }),
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
              const SizedBox(height: 10),
            ],
          ),
          const SizedBox(width: 20),
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
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
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
