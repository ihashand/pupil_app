// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';

void showAddMedicine(BuildContext context, WidgetRef ref,
    {required String petId}) {
  final formKey = GlobalKey<FormState>();

  // Kontrolery do pól formularza
  final nameController = TextEditingController();
  final frequencyController = TextEditingController();
  final dosageController = TextEditingController();
  final emojiController = TextEditingController();

  bool remindersEnabled = false;

  void saveMedicine() async {
    if (formKey.currentState?.validate() ?? false) {
      final newMedicine = EventMedicineModel(
        id: generateUniqueId(),
        name: nameController.text,
        petId: petId,
        eventId: generateUniqueId(),
        frequency: frequencyController.text,
        dosage: dosageController.text,
        emoji: emojiController.text,
        remindersEnabled: remindersEnabled,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      // Zapisz nowy lek
      await ref.read(eventMedicineServiceProvider).addMedicine(newMedicine);

      Navigator.of(context).pop();
    }
  }

  // Zbudowanie UI dla showModalBottomSheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            'Add New Medicine',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: saveMedicine,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      height: 32,
                    ),

                    // Pole do wpisania nazwy leku
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Medicine Name',
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColorDark,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the medicine name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Pole do wpisania częstotliwości
                          TextFormField(
                            controller: frequencyController,
                            decoration: InputDecoration(
                              labelText: 'Frequency',
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColorDark,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the frequency';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Pole do wpisania dawki
                          TextFormField(
                            controller: dosageController,
                            decoration: InputDecoration(
                              labelText: 'Dosage',
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColorDark,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the dosage';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Pole do wyboru emoji
                          TextFormField(
                            controller: emojiController,
                            decoration: InputDecoration(
                              labelText: 'Emoji',
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColorDark,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an emoji';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Przełącznik dla przypomnień
                          SwitchListTile(
                            title: const Text('Enable Reminders'),
                            value: remindersEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                remindersEnabled = value;
                              });
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
