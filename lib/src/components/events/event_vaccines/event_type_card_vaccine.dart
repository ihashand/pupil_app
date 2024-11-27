import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_vacine_provider.dart';
import 'package:pet_diary/src/screens/other_screens/add_reminder_screen.dart';

void showVaccineOptions(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDateTime = DateTime.now();
  TimeOfDay? selectedTime;
  bool showDetails = false;
  String? selectedVaccineType;
  TextEditingController otherVaccineController = TextEditingController();

  final List<Map<String, dynamic>> vaccineTypes = [
    {'icon': Icons.vaccines, 'description': 'Rabies', 'color': Colors.red},
    {'icon': Icons.science, 'description': 'Distemper', 'color': Colors.green},
    {'icon': Icons.biotech, 'description': 'Hepatitis', 'color': Colors.blue},
    {
      'icon': Icons.coronavirus,
      'description': 'Bordatella',
      'color': Colors.orange
    },
    {
      'icon': Icons.bug_report,
      'description': 'Leptospirosis',
      'color': Colors.purple
    },
    {'icon': Icons.healing, 'description': 'Parvovirus', 'color': Colors.pink},
    {
      'icon': Icons.sanitizer,
      'description': 'Parainfluenza',
      'color': Colors.teal
    },
    {
      'icon': Icons.local_hospital,
      'description': 'Adenovirus',
      'color': Colors.indigo
    },
    {'icon': Icons.other_houses, 'description': 'Other', 'color': Colors.grey},
  ];

  void recordVaccineEvent() {
    String eventId = generateUniqueId();
    String description = selectedVaccineType == "Other"
        ? otherVaccineController.text
        : selectedVaccineType ?? 'Vaccine event';

    if (petIds != null && petIds.isNotEmpty) {
      for (String id in petIds) {
        _saveVaccineEvent(
            ref, id, eventId, description, selectedDateTime, selectedTime);
      }
    } else if (petId != null) {
      _saveVaccineEvent(
          ref, petId, eventId, description, selectedDateTime, selectedTime);
    }

    // Wyświetlenie dialogu z pytaniem o przypomnienie po zapisaniu szczepionki
    Future.delayed(Duration.zero, () {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Set Reminder?'),
            content: const Text(
              'Do you want to set a reminder for the next vaccine?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Zamknij dialog bez akcji
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Zamknij dialog
                  // Przejdź do ekranu dodawania przypomnienia
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddReminderScreen(),
                    ),
                  );
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    });
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final double screenHeight = MediaQuery.of(context).size.height;
          double initialSize = screenHeight > 800 ? 0.22 : 0.25;
          double detailsSize = screenHeight > 800 ? 0.5 : 0.6;
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
                            'V A C C I N E S',
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
                              recordVaccineEvent();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Padding(
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
                        ),
                      ),
                    ),
                    // Kontener dla wyboru szczepionki
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: vaccineTypes.map((type) {
                                  bool isSelected = type['description'] ==
                                      selectedVaccineType;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVaccineType =
                                            type['description'];
                                        if (selectedVaccineType != "Other") {
                                          otherVaccineController.clear();
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            type['icon'],
                                            size: 50,
                                            color: isSelected
                                                ? type['color']
                                                : Colors.grey,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            type['description'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Kontener dla wyboru daty, godziny oraz pola tekstowego dla "Other"
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              if (selectedVaccineType == "Other") ...[
                                TextField(
                                  controller: otherVaccineController,
                                  decoration: InputDecoration(
                                    labelText: "Enter Vaccine Name",
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
                              GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showStyledDatePicker(
                                    context: context,
                                    initialDate: selectedDateTime,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDateTime = pickedDate;
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
                                        .format(selectedDateTime),
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

void _saveVaccineEvent(WidgetRef ref, String petId, String eventId,
    String description, DateTime date, TimeOfDay? time) {
  final newVaccine = EventVaccineModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    userId: FirebaseAuth.instance.currentUser!.uid,
    emoticon: '💉',
    description: description,
    dateTime: date,
    time: time,
  );

  ref.read(eventVaccineServiceProvider).addVaccine(newVaccine);

  final newEvent = Event(
    id: eventId,
    title: 'Vaccine',
    eventDate: date,
    dateWhenEventAdded: DateTime.now(),
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    description: description,
    avatarImage: 'assets/images/vaccine.png',
    emoticon: '💉',
    vaccineId: newVaccine.id,
  );

  ref.read(eventServiceProvider).addEvent(newEvent);
}

Widget eventTypeCardVaccines(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'V A C C I N E S',
    'assets/images/events_type_cards_no_background/syringe.png',
    () => showVaccineOptions(context, ref, petId: petId, petIds: petIds),
  );
}
