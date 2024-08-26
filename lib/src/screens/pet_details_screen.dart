import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_icon_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_name_age_button_widget.dart';
import 'package:pet_diary/src/helper/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/models/event_weight_model.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/event_weight_provider.dart';
import 'package:pet_diary/src/screens/pet_edit_screen.dart';
import 'package:pet_diary/src/widgets/health_events_widgets/health_event_card.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/event_tile.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/functions/show_event_type_selection.dart';

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
  DateTime selectedDateTime = DateTime.now();
  Pet? _pet;
  Map<String, bool> expandedEvents = {};

  @override
  void initState() {
    super.initState();
    _fetchPet();
  }

  Future<void> _fetchPet() async {
    final petService = ref.read(petServiceProvider);
    final fetchedPet = await petService.getPetById(widget.petId);
    setState(() {
      _pet = fetchedPet;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet;
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              iconSize: 25,
              color: Colors.black,
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
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: GestureDetector(
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
                            backgroundColor: Colors.transparent,
                            backgroundImage: pet.avatarImage.isNotEmpty
                                ? AssetImage(pet.avatarImage)
                                : null,
                            radius: 65,
                          ),
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: SizedBox(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 150,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  HealthEventCard(
                    onCreatePressed: () =>
                        showEventTypeSelection(context, ref, widget.petId),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'E V E N T S',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).primaryColorDark,
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
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          const Text('Error fetching events'),
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
                                  event.eventDate.month ==
                                      nextEventDate.month &&
                                  event.eventDate.day == nextEventDate.day)
                              .toList();
                        }

                        if (eventsToShow.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'No events yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 200,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: eventsToShow.length,
                          itemBuilder: (context, index) {
                            final currentEvent = eventsToShow[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  expandedEvents[currentEvent.id] =
                                      !(expandedEvents[currentEvent.id] ??
                                          false);
                                });
                              },
                              child: EventTile(
                                event: currentEvent,
                                isExpanded:
                                    expandedEvents[currentEvent.id] ?? false,
                                ref: ref,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PetDetailNameAgeButtonWidget(
                    buttonColor: Theme.of(context).colorScheme.inversePrimary,
                    petId: widget.petId,
                  ),
                  const SizedBox(height: 10),
                  Consumer(builder: (context, ref, _) {
                    final asyncWeights = ref.watch(eventWeightsProvider);
                    return asyncWeights.when(
                      loading: () => const Text('Loading...'),
                      error: (err, stack) =>
                          const Text('Error fetching weights'),
                      data: (weights) {
                        var weight = weights
                            .firstWhere(
                              (element) => element!.petId == widget.petId,
                              orElse: () => EventWeightModel(
                                id: '',
                                weight: 0.0,
                                eventId: '',
                                petId: widget.petId,
                                dateTime: DateTime.now(),
                              ),
                            )!
                            .weight;
                        return PetDetailIconWidget(
                          petId: pet.id,
                          weight: weight.toString(),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
