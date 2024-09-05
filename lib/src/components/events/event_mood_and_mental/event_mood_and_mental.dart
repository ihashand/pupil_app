import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';
import 'package:pet_diary/src/models/events_models/event_psychic_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_mood_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_psychic_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

Widget eventTypeCardMoodAndMental(BuildContext context, WidgetRef ref,
    String petId, TextEditingController dateController) {
  DateTime selectedDate = DateTime.now();
  dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);

  final List<Map<String, dynamic>> moods = [
    {'icon': '😄', 'description': 'Happy'},
    {'icon': '😃', 'description': 'Excited'},
    {'icon': '😊', 'description': 'Content'},
    {'icon': '😐', 'description': 'Neutral'},
    {'icon': '😴', 'description': 'Tired'},
    {'icon': '😢', 'description': 'Sad'},
    {'icon': '😠', 'description': 'Angry'},
    {'icon': '😡', 'description': 'Furious'},
    {'icon': '😭', 'description': 'Crying'},
    {'icon': '😞', 'description': 'Disappointed'},
  ];

  final List<Map<String, dynamic>> psychicIssues = [
    {'icon': '😰', 'description': 'Anxiety'},
    {'icon': '😴', 'description': 'Insomnia'},
    {'icon': '😟', 'description': 'Stress'},
    {'icon': '😨', 'description': 'Fear'},
    {'icon': '😡', 'description': 'Irritability'},
    {'icon': '😩', 'description': 'Fatigue'},
    {'icon': '🤔', 'description': 'Lack of Concentration'},
    {'icon': '😕', 'description': 'Confusion'},
    {'icon': '😴', 'description': 'Laziness'},
    {'icon': '🤪', 'description': 'Hyperactivity'},
  ];

  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.close,
                                    color: Theme.of(context).primaryColorDark),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              Text(
                                'M O O D & M E N T A L',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              IconButton(
                                icon: Icon(Icons.check,
                                    color: Theme.of(context).primaryColorDark),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: dateController,
                                        decoration: InputDecoration(
                                          labelText: 'Date',
                                          labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          final DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: selectedDate,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme:
                                                      ColorScheme.light(
                                                    primary: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    onPrimary: Theme.of(context)
                                                        .primaryColorDark,
                                                    onSurface: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .primaryColorDark,
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (picked != null &&
                                              picked != selectedDate) {
                                            setState(() {
                                              selectedDate = picked;
                                              dateController.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(selectedDate);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text('Mood',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: moods.map((mood) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Logika zapisu wydarzenia Mood
                                              String eventId =
                                                  generateUniqueId();
                                              int moodRating = EventMoodModel
                                                  .determineMoodRating(
                                                      mood['icon']);
                                              EventMoodModel newMood =
                                                  EventMoodModel(
                                                id: generateUniqueId(),
                                                eventId: eventId,
                                                petId: petId,
                                                emoji: mood['icon'],
                                                description:
                                                    mood['description'],
                                                dateTime: selectedDate,
                                                moodRating: moodRating,
                                              );
                                              ref
                                                  .read(
                                                      eventMoodServiceProvider)
                                                  .addMood(newMood);

                                              Event newEvent = Event(
                                                id: eventId,
                                                title: 'Mood',
                                                eventDate: selectedDate,
                                                dateWhenEventAdded:
                                                    DateTime.now(),
                                                userId: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                petId: petId,
                                                description:
                                                    mood['description'],
                                                avatarImage:
                                                    'assets/images/dog_avatar_014.png',
                                                emoticon: mood['icon'],
                                                moodId: newMood.id,
                                              );
                                              ref
                                                  .read(eventServiceProvider)
                                                  .addEvent(newEvent);
                                              Navigator.of(context).pop();
                                            },
                                            child: CircleAvatar(
                                              radius: 30,
                                              child: Text(
                                                mood['icon'],
                                                style: const TextStyle(
                                                    fontSize: 30),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            mood['description'],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text('Psychic Issues',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: psychicIssues.map((issue) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Logika zapisu wydarzenia Psychic
                                              String eventId =
                                                  generateUniqueId();
                                              EventPsychicModel newPsychic =
                                                  EventPsychicModel(
                                                id: generateUniqueId(),
                                                eventId: eventId,
                                                petId: petId,
                                                emoji: issue['icon'],
                                                description:
                                                    issue['description'],
                                                dateTime: selectedDate,
                                              );
                                              ref
                                                  .read(
                                                      eventPsychicServiceProvider)
                                                  .addPsychicEvent(newPsychic);

                                              Event newEvent = Event(
                                                id: eventId,
                                                title: 'Psychic',
                                                eventDate: selectedDate,
                                                dateWhenEventAdded:
                                                    DateTime.now(),
                                                userId: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                petId: petId,
                                                description:
                                                    issue['description'],
                                                avatarImage:
                                                    'assets/images/dog_avatar_014.png',
                                                emoticon: issue['icon'],
                                                psychicId: newPsychic.id,
                                              );
                                              ref
                                                  .read(eventServiceProvider)
                                                  .addEvent(newEvent);
                                              Navigator.of(context).pop();
                                            },
                                            child: CircleAvatar(
                                              radius: 30,
                                              child: Text(
                                                issue['icon'],
                                                style: const TextStyle(
                                                    fontSize: 30),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            issue['description'],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              image: DecorationImage(
                image:
                    AssetImage('assets/images/health_event_card/dog_love.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 13.0, left: 5, right: 5),
            child: Text(
              'Mood & Mental',
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
