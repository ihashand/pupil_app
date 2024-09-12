import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_care_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

Widget eventTypeCardCare(BuildContext context, WidgetRef ref, String petId,
    TextEditingController dateController) {
  DateTime selectedDate = DateTime.now();
  dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);

  final List<Map<String, dynamic>> careOptions = [
    {'icon': '🛁', 'description': 'Bathing'},
    {'icon': '✂️', 'description': 'Nail Trimming'},
    {'icon': '🧼', 'description': 'Brushing'},
    {'icon': '👀', 'description': 'Eye Cleaning'},
    {'icon': '👂', 'description': 'Ear Cleaning'},
    {'icon': '🧴', 'description': 'Cream Application'},
    {'icon': '🪲', 'description': 'Tick Check'},
    {'icon': '🐜', 'description': 'Flea Check'},
    {'icon': '🪥', 'description': 'Teeth Brushing'},
    {'icon': '👣', 'description': 'Paw Care'},
    {'icon': '🦷', 'description': 'Dental Check'},
    {'icon': '✂️', 'description': 'Trimming Hair Around Eyes'},
    {'icon': '🔍', 'description': 'Skin Check'},
    {'icon': '💆‍♂️', 'description': 'Relaxation Massage'},
    {'icon': '👃', 'description': 'Nose Health Check'},
    {'icon': '👁️', 'description': 'Eye Drops'},
    {'icon': '🧴', 'description': 'Moisturizing Paw Pads'},
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
                                'C A R E',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              IconButton(
                                icon: Icon(Icons.check,
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0)),
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
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: careOptions.map((option) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Care Option'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                            'Are you sure you want to add this care option?'),
                                                        Text(
                                                          option['icon'],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 50),
                                                        ),
                                                        Text(option[
                                                            'description']),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          'Confirm',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                        ),
                                                        onPressed: () {
                                                          String eventId =
                                                              generateUniqueId();

                                                          EventCareModel
                                                              newCare =
                                                              EventCareModel(
                                                            id: generateUniqueId(),
                                                            eventId: eventId,
                                                            petId: petId,
                                                            careType: option[
                                                                'description'],
                                                            emoji:
                                                                option['icon'],
                                                            description: option[
                                                                'description'],
                                                            dateTime:
                                                                selectedDate,
                                                          );

                                                          ref
                                                              .read(
                                                                  eventCareServiceProvider)
                                                              .addCare(newCare);

                                                          Event newEvent =
                                                              Event(
                                                            id: eventId,
                                                            title: 'Care',
                                                            eventDate:
                                                                selectedDate,
                                                            dateWhenEventAdded:
                                                                DateTime.now(),
                                                            userId: FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            petId: petId,
                                                            description: option[
                                                                'description'],
                                                            avatarImage:
                                                                'assets/images/dog_avatar_014.png',
                                                            emoticon:
                                                                option['icon'],
                                                            careId: newCare.id,
                                                          );

                                                          ref
                                                              .read(
                                                                  eventServiceProvider)
                                                              .addEvent(
                                                                  newEvent);

                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: 30,
                                              child: Text(
                                                option['icon'],
                                                style: const TextStyle(
                                                    fontSize: 30),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            option['description'],
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
                    AssetImage('assets/images/health_event_card/dog_bath.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 13.0, left: 5, right: 5),
            child: Text(
              'C A R E',
              style: TextStyle(
                fontSize: 13,
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
