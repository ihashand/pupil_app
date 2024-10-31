import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_mood_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

void showMoodOptions(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool showDetails = false;
  String? selectedMood;

  final double screenHeight = MediaQuery.of(context).size.height;
  double initialSize = screenHeight > 800 ? 0.28 : 0.38;
  double detailsSize = screenHeight > 800 ? 0.48 : 0.58;
  double maxSize = screenHeight > 800 ? 1 : 1;

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

  void recordMoodEvent() {
    String eventId = generateUniqueId();
    int moodRating = EventMoodModel.determineMoodRating(selectedMood!);
    String selectedEmoji = moods
        .firstWhere((mood) => mood['description'] == selectedMood)['emoji'];

    if (petIds != null && petIds.isNotEmpty) {
      for (String id in petIds) {
        _saveMoodEvent(ref, id, eventId, selectedMood!, selectedEmoji,
            moodRating, selectedDate, selectedTime);
      }
    } else if (petId != null) {
      _saveMoodEvent(ref, petId, eventId, selectedMood!, selectedEmoji,
          moodRating, selectedDate, selectedTime);
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: showDetails ? detailsSize : initialSize,
            minChildSize: initialSize,
            maxChildSize: maxSize,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                                  recordMoodEvent();
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
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
                                                ? Colors.blue
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
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 150,
                                height: 30,
                                child: showDetails
                                    ? IconButton(
                                        icon: const Icon(Icons.more_horiz),
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.6),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: Text(
                                          "M O R E",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showStyledDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Date',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(selectedDate),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  final pickedTime = await showStyledTimePicker(
                                    context: context,
                                    initialTime:
                                        selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Time',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    selectedTime != null
                                        ? selectedTime!.format(context)
                                        : 'Select Time',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
    },
  );
}

void _saveMoodEvent(WidgetRef ref, String petId, String eventId,
    String description, String emoji, int moodRating, DateTime date,
    [TimeOfDay? time]) {
  final newMood = EventMoodModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    userId: FirebaseAuth.instance.currentUser!.uid,
    emoji: emoji,
    description: description,
    dateTime: date,
    time: time,
    moodRating: moodRating,
  );

  ref.read(eventMoodServiceProvider).addMood(newMood);

  final newEvent = Event(
    id: eventId,
    title: 'Mood',
    eventDate: date,
    dateWhenEventAdded: DateTime.now(),
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    description: description,
    avatarImage: 'assets/images/dog_avatar_014.png',
    emoticon: emoji,
    moodId: newMood.id,
  );

  ref.read(eventServiceProvider).addEvent(newEvent, petId);
}

// Główny widget karty dla mood
Widget eventTypeCardMood(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'M O O D',
    'assets/images/events_type_cards_no_background/heart.png',
    () => showMoodOptions(context, ref, petId: petId, petIds: petIds),
  );
}
