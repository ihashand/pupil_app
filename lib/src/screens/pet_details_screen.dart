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
import 'package:pet_diary/src/widgets/pet_details_widgets/event_tile.dart';

class HealthEventCard extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const HealthEventCard({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/health_event_card/health_event_card.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                alignment: Alignment.center,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Intuitive way to add new health events for your pet!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xff68a2b6),
                        minimumSize: const Size(150, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onCreatePressed,
                      child: Text(
                        'C r e a t e',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  void _showEventTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: true,
          initialChildSize: 0.94,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Choose Event Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      controller: scrollController,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      children: [
                        _buildEventTypeCard(context, 'Notes',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Notes screen
                        }),
                        _buildEventTypeCard(context, 'Feeding',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Feeding screen
                        }),
                        _buildEventTypeCard(context, 'Mesuring',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Weight & Temperature screen
                        }),
                        _buildEventTypeCard(context, 'Grooming',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Grooming screen
                        }),
                        _buildEventTypeCard(context, 'Mood & Mental',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Mood & Mental Health screen
                        }),
                        _buildEventTypeCard(context, 'Physiologic',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Physiological Needs screen
                        }),
                        _buildEventTypeCard(context, 'Medications',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Medications & Vaccines screen
                        }),
                        _buildEventTypeCard(context, 'Others',
                            'assets/images/achievements/natural/nileriver.jpeg',
                            () {
                          // TODO: Implement navigation to Medications & Vaccines screen
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventTypeCard(BuildContext context, String title,
      String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 5, right: 5),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
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
            top: 150, // Przestrzeń na statyczny sektor
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                      height: 20), // Przestrzeń na zaokrąglony sektor
                  HealthEventCard(
                    onCreatePressed: () => _showEventTypeSelection(context),
                  ), // Nowa karta dodawania wydarzeń zdrowotnych
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
