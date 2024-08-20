import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_icon_widget.dart';
import 'package:pet_diary/src/components/pet_detail/pet_detail_name_age_button_widget.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/helper/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/models/event_weight_model.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_note_provider.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/event_weight_provider.dart';
import 'package:pet_diary/src/screens/pet_edit_screen.dart';
import 'package:pet_diary/src/widgets/health_events_widgets/health_event_card.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/event_tile.dart';

import '../models/event_note_model.dart';

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
    var titleController = TextEditingController();
    var contentTextController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      children: [
                        buildEventTypeCardNotes(
                            context, titleController, contentTextController),
                        _buildEventTypeCard(context, 'Feeding',
                            'assets/images/health_event_card/dog_bowl_02.png',
                            () {
                          // TODO: Implement navigation to Feeding screen
                        }),
                        _buildEventTypeCard(context, 'Mesuring',
                            'assets/images/health_event_card/termometr.png',
                            () {
                          // TODO: Implement navigation to Weight & Temperature screen
                        }),
                        _buildEventTypeCard(context, 'Grooming',
                            'assets/images/health_event_card/hair_brush.png',
                            () {
                          // TODO: Implement navigation to Grooming screen
                        }),
                        _buildEventTypeCard(context, 'Mood & Mental',
                            'assets/images/health_event_card/dog_love.png', () {
                          // TODO: Implement navigation to Mood & Mental Health screen
                        }),
                        _buildEventTypeCard(context, 'Physiologic',
                            'assets/images/health_event_card/poo.png', () {
                          // TODO: Implement navigation to Physiological Needs screen
                        }),
                        _buildEventTypeCard(context, 'Medications',
                            'assets/images/health_event_card/pills.png', () {
                          // TODO: Implement navigation to Medications & Vaccines screen
                        }),
                        _buildEventTypeCard(context, 'Others',
                            'assets/images/health_event_card/others.png', () {
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

  Widget buildEventTypeCardNotes(
      BuildContext context,
      TextEditingController titleController,
      TextEditingController contentTextController) {
    return _buildEventTypeCard(
      context,
      'Notes',
      'assets/images/health_event_card/notes.png',
      () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled:
              true, // Umożliwia dynamiczne dopasowanie wysokości
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height *
                  0.71, // Zwiększenie wysokości
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .max, // Zwiększa wysokość kolumny do maksymalnej dostępnej wysokości
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8, top: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 107),
                          child: Text(
                            'N O T E S',
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
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                            child: TextFormField(
                              controller: titleController,
                              keyboardType: TextInputType.text,
                              cursorColor: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Note',
                              border: OutlineInputBorder(),
                            ),
                            child: TextFormField(
                              controller: contentTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 10, // Zwiększenie liczby linii
                              textAlign: TextAlign.start,
                              cursorColor: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 25, left: 25, bottom: 0, top: 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double
                            .infinity, // Szerokość przycisku wypełnia całą dostępną szerokość
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xff68a2b6), // Kolor tła przycisku
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            if (titleController.text.isEmpty &&
                                contentTextController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Error',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 24,
                                      ),
                                    ),
                                    content: Text(
                                      'Fields cannot be empty.',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 16,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            String eventId = generateUniqueId();
                            String noteId = generateUniqueId();
                            EventNoteModel newNote = EventNoteModel(
                              id: noteId,
                              title: titleController.text,
                              eventId: eventId,
                              petId: widget.petId,
                              dateTime: DateTime.now(),
                              contentText: contentTextController.text,
                            );

                            Event newEvent = Event(
                              id: eventId,
                              title: 'Note',
                              eventDate: DateTime.now(),
                              dateWhenEventAdded: DateTime.now(),
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              petId: widget.petId,
                              weightId: '',
                              temperatureId: '',
                              walkId: '',
                              waterId: '',
                              noteId: newNote.id,
                              pillId: '',
                              description:
                                  '${newNote.title} /n ${newNote.contentText}',
                              proffesionId: 'NONE',
                              personId: 'NONE',
                              avatarImage: 'assets/images/dog_avatar_014.png',
                              emoticon: '📝',
                              moodId: '',
                              stomachId: '',
                              psychicId: '',
                              stoolId: '',
                              urineId: '',
                              serviceId: '',
                              careId: '',
                            );

                            ref.read(eventServiceProvider).addEvent(newEvent);
                            ref.read(eventNoteServiceProvider).addNote(newNote);

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'S A V E',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
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
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 13.0, left: 5, right: 5),
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
