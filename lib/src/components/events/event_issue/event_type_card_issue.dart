import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_issue_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/providers/events_providers/event_psychic_provider.dart';

void showIssuesOptions(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool showDetails = false;
  String? selectedIssue;
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );
  TextEditingController otherIssueController = TextEditingController();

  final List<Map<String, dynamic>> issues = [
    {'emoji': '🤕', 'description': 'Pain'},
    {'emoji': '🤧', 'description': 'Fever'},
    {'emoji': '🤮', 'description': 'Vomiting'},
    {'emoji': '😰', 'description': 'Anxiety'},
    {'emoji': '😱', 'description': 'Panic'},
    {'emoji': '🥵', 'description': 'Hot'},
    {'emoji': '🥶', 'description': 'Cold'},
    {'emoji': '❓', 'description': 'Other'},
  ];

  void recordIssueEvent() {
    String eventId = generateUniqueId();
    String selectedEmoji = issues.firstWhere(
      (issue) => issue['description'] == selectedIssue,
      orElse: () => {'emoji': ''},
    )['emoji'] as String;

    String issueDescription = selectedIssue == "Other"
        ? otherIssueController.text
        : selectedIssue ?? 'Issue';

    if (petIds != null && petIds.isNotEmpty) {
      for (String id in petIds) {
        _saveIssueEvent(ref, id, eventId, issueDescription, selectedEmoji,
            selectedDate, selectedTime);
      }
    } else if (petId != null) {
      _saveIssueEvent(ref, petId, eventId, issueDescription, selectedEmoji,
          selectedDate, selectedTime);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final double screenHeight = MediaQuery.of(context).size.height;
          double initialSize = screenHeight > 800 ? 0.3 : 0.35;
          double detailsSize = screenHeight > 800 ? 0.55 : 0.7;
          double maxSize = screenHeight > 800 ? 1 : 1;

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
                    // Nagłówek
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Text(
                            'I S S U E S',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              if (selectedIssue != null) {
                                recordIssueEvent();
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Pierwszy kontener z wyborem Issue i przyciskiem "More Details"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 12),
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
                                children: issues.map((issue) {
                                  bool isSelected =
                                      selectedIssue == issue['description'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIssue = issue['description'];
                                        if (selectedIssue == "Other") {
                                          otherIssueController
                                              .clear(); // Reset field for Other issue
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                            child: Text(
                                              issue['emoji'],
                                              style:
                                                  const TextStyle(fontSize: 30),
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
                    // Drugi kontener z wyborem daty i czasu
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              // Pole tekstowe dla 'Other Issue'
                              if (selectedIssue == "Other") ...[
                                TextField(
                                  controller: otherIssueController,
                                  decoration: InputDecoration(
                                    labelText: "Enter Issue Description",
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
                                ),
                                const SizedBox(height: 10),
                              ],
                              // Wybór daty
                              GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                      dateController.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(selectedDate);
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
                              // Wybór czasu
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

void _saveIssueEvent(WidgetRef ref, String petId, String eventId,
    String description, String emoji, DateTime date, TimeOfDay? time) {
  final newIssue = EventIssueModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    userId: FirebaseAuth.instance.currentUser!.uid,
    emoji: emoji,
    description: description,
    dateTime: date,
    time: time,
  );

  ref.read(eventIssueServiceProvider).addIssue(newIssue);

  final newEvent = Event(
    id: eventId,
    title: 'Issue',
    eventDate: date,
    dateWhenEventAdded: DateTime.now(),
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    description: description,
    avatarImage: 'assets/images/issue_icon.png',
    emoticon: emoji,
    issueId: newIssue.id,
  );

  ref.read(eventServiceProvider).addEvent(newEvent, petId);
}

// Główny widget karty dla issues
Widget eventTypeCardIssues(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'I S S U E S',
    'assets/images/events_type_cards_no_background/issue.png',
    () => showIssuesOptions(context, ref, petId: petId, petIds: petIds),
  );
}
