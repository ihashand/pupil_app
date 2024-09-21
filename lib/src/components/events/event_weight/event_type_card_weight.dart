import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_weight_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardWeight(BuildContext context, WidgetRef ref, String petId) {
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );
  TextEditingController weightController = TextEditingController();
  double initialWeight = 0;

  void showWeightModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                              'W E I G H T',
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
                                if (weightController.text.trim().isEmpty ||
                                    initialWeight <= 0.0) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Invalid Input',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: 24)),
                                        content: SizedBox(
                                          width: 250,
                                          child: Text(
                                              'Weight field cannot be empty.',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 16)),
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
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }

                                if (initialWeight > 200.0) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Invalid Input',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: 24)),
                                        content: SizedBox(
                                          width: 250,
                                          child: Text(
                                              'Weight cannot exceed 200 kg.',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 16)),
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
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }

                                String eventId = generateUniqueId();
                                String weightId = generateUniqueId();
                                EventWeightModel newWeight = EventWeightModel(
                                    id: weightId,
                                    eventId: eventId,
                                    petId: petId,
                                    weight: initialWeight,
                                    dateTime: selectedDate);

                                Event newEvent = Event(
                                  id: eventId,
                                  eventDate: selectedDate,
                                  dateWhenEventAdded: DateTime.now(),
                                  title: 'Weight',
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: petId,
                                  weightId: newWeight.id,
                                  description: '$initialWeight',
                                  avatarImage:
                                      'assets/images/dog_avatar_012.png',
                                  emoticon: '⚖️',
                                );

                                ref
                                    .read(eventServiceProvider)
                                    .addEvent(newEvent);
                                ref
                                    .read(eventWeightServiceProvider)
                                    .addWeight(newWeight);

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
                            SizedBox(
                              width: double.infinity,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Weight',
                                  border: OutlineInputBorder(),
                                ),
                                child: TextFormField(
                                  controller: weightController,
                                  cursorColor: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.5),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (value) {
                                    final fixedValue =
                                        value.replaceAll(',', '.');
                                    initialWeight =
                                        double.tryParse(fixedValue) ?? 0.0;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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
    'W E I G H T',
    'assets/images/events_type_cards_no_background/weight.png',
    () {
      showWeightModal(context);
    },
  );
}
