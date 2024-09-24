import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_mood_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardMood(BuildContext context, WidgetRef ref, String petId,
    TextEditingController dateController) {
  DateTime selectedDate = DateTime.now();
  dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);

  String? selectedMood;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'description': 'Calm'},
    {'emoji': '😃', 'description': 'Energetic'},
    {'emoji': '🤪', 'description': 'Goofy'},
    {'emoji': '😁', 'description': 'Confident'},
    {'emoji': '😌', 'description': 'Satisfied'},
    {'emoji': '😍', 'description': 'Loving'},
    {'emoji': '😇', 'description': 'Safe'},
    {'emoji': '🥳', 'description': 'Excited'},
    {'emoji': '😋', 'description': 'Satisfied'},
    {'emoji': '😴', 'description': 'Tired'},
  ];

  void showMoodOptions(BuildContext context) {
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
                              'M O O D',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                                icon: Icon(Icons.check,
                                    color: Theme.of(context).primaryColorDark),
                                onPressed: () {
                                  if (selectedMood != null) {
                                    String eventId = generateUniqueId();
                                    int moodRating =
                                        EventMoodModel.determineMoodRating(
                                            selectedMood!);
                                    String selectedEmoji = moods.firstWhere(
                                        (mood) =>
                                            mood['description'] ==
                                            selectedMood)['emoji'];

                                    EventMoodModel newMood = EventMoodModel(
                                      id: generateUniqueId(),
                                      eventId: eventId,
                                      petId: petId,
                                      emoji: selectedEmoji,
                                      description: selectedMood!,
                                      dateTime: selectedDate,
                                      moodRating: moodRating,
                                    );

                                    ref
                                        .read(eventMoodServiceProvider)
                                        .addMood(newMood);

                                    Event newEvent = Event(
                                      id: eventId,
                                      title: 'Mood',
                                      eventDate: selectedDate,
                                      dateWhenEventAdded: DateTime.now(),
                                      userId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      petId: petId,
                                      description: selectedMood!,
                                      avatarImage:
                                          'assets/images/dog_avatar_014.png',
                                      emoticon: selectedEmoji,
                                      moodId: newMood.id,
                                    );

                                    ref
                                        .read(eventServiceProvider)
                                        .addEvent(newEvent, petId);
                                  }
                                  Navigator.of(context).pop();
                                }),
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
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
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
                            const Text('M O O D',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: moods.map((mood) {
                                  bool isSelected =
                                      selectedMood == mood['description'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedMood = mood['description'];
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: isSelected
                                                ? Colors.blueGrey
                                                : Colors.transparent,
                                            child: Text(
                                              mood['emoji'],
                                              style:
                                                  const TextStyle(fontSize: 30),
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
  }

  return eventTypeCard(
    context,
    'M O O D',
    'assets/images/events_type_cards_no_background/heart.png',
    () {
      showMoodOptions(context);
    },
  );
}
