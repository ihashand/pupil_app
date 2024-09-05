import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_vacine_provider.dart';
import 'package:pet_diary/src/screens/medicine_screens/medicine_screen.dart';

Widget eventTypeCardMedicine(
    BuildContext context, WidgetRef ref, String petId) {
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );

  // todo generate icons for vacines

  final List<Map<String, dynamic>> vaccineTypes = [
    {'icon': '🦠', 'description': 'Rabies'},
    {'icon': '💊', 'description': 'Distemper'},
    {'icon': '🧬', 'description': 'Hepatitis'},
    {'icon': '🧪', 'description': 'Bordatella'},
    {'icon': '💉', 'description': 'Parvovirus'},
    {'icon': '🐛', 'description': 'Leptospirosis'},
    {'icon': '🐕', 'description': 'Lyme Disease'},
    {'icon': '🦊', 'description': 'Coronavirus'},
    {'icon': '🌡️', 'description': 'Giardina'},
    {'icon': '🐍', 'description': 'Canine Influenza H3N8'},
  ];

  String? selectedVaccineType;
  bool showDetails = false;

  void showConfirmationDialog(
      BuildContext context, String eventType, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirm $eventType Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to add $eventType? You can optionally add more details by pressing the button below.',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColorDark),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showDetails = !showDetails;
                      });
                    },
                    child: Text(
                      showDetails ? 'Hide Details' : 'Show Details',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 14),
                    ),
                  ),
                  if (showDetails)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: vaccineTypes.map((type) {
                          bool isSelected =
                              type['description'] == selectedVaccineType;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVaccineType = type['description'];
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 110,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryFixedDim
                                    : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(type['icon'],
                                      style: const TextStyle(fontSize: 40)),
                                  const SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      type['description'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .primaryColorDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close modal
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void recordVaccineEvent() {
    String eventId = generateUniqueId();
    EventVaccineModel newVaccine = EventVaccineModel(
      id: generateUniqueId(),
      eventId: eventId,
      petId: petId,
      emoticon: selectedVaccineType ?? 'Default',
      description: selectedVaccineType ?? 'Vaccine event',
      dateTime: selectedDate,
    );
    ref.read(eventVaccineServiceProvider).addVaccine(newVaccine);

    Event newEvent = Event(
      id: eventId,
      title: 'Vaccine',
      eventDate: selectedDate,
      dateWhenEventAdded: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: petId,
      description: selectedVaccineType ?? 'Vaccine event',
      avatarImage: 'assets/images/dog_avatar_014.png',
      emoticon: '💉',
      vaccineId: newVaccine.id,
    );
    ref.read(eventServiceProvider).addEvent(newEvent);
  }

  return eventTypeCard(
    context,
    'Medicine & Vaccines',
    'assets/images/health_event_card/pills.png',
    () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
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
                              'M E D I C I N E  &  V A C C I N E S',
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
                                Navigator.of(context).pop();
                              },
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: dateController,
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      labelStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Przekierowanie na ekran MedicineScreen
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MedicineScreen(petId),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      width: 150,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('💊',
                                              style: TextStyle(fontSize: 40)),
                                          const SizedBox(height: 8),
                                          Text('Medicine',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => showConfirmationDialog(
                                        context, 'Vaccine', recordVaccineEvent),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      width: 150,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('💉',
                                              style: TextStyle(fontSize: 40)),
                                          const SizedBox(height: 8),
                                          Text('Vaccines',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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
