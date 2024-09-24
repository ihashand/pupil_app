// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_emoji.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

void showAddMedicineSummary(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType,
    String strength,
    String unit,
    String frequency,
    String emoji,
    String scheduleDetails) {
  final formKey = GlobalKey<FormState>();

  void saveMedicineAndEvent(
      BuildContext context,
      WidgetRef ref,
      String petId,
      String medicineName,
      DateTime startDate,
      DateTime endDate,
      String medicineType,
      String strength,
      String unit,
      String frequency,
      String emoji,
      String scheduleDetails) async {
    try {
      if (!Navigator.canPop(context)) return;

      String eventId = generateUniqueId();

      final newMedicine = EventMedicineModel(
          id: generateUniqueId(),
          name: medicineName,
          petId: petId,
          eventId: eventId,
          frequency: frequency,
          dosage: '$strength $unit',
          emoji: emoji,
          startDate: startDate,
          endDate: endDate,
          remindersEnabled: false,
          scheduleDetails: scheduleDetails,
          medicineType: medicineType);

      await ref.read(eventMedicineServiceProvider).addMedicine(newMedicine);

      Event newEvent = Event(
        id: eventId,
        title: medicineName,
        eventDate: startDate,
        dateWhenEventAdded: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        petId: petId,
        description: 'Medicine: $medicineName, Schedule: $scheduleDetails',
        pillId: newMedicine.id,
        avatarImage: 'assets/images/pill_avatar.png',
        emoticon: emoji,
      );

      await ref.read(eventServiceProvider).addEvent(newEvent, petId);

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: formKey,
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
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).primaryColorDark,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              showAddMedicineEmoji(
                                  context,
                                  ref,
                                  petId,
                                  medicineName,
                                  startDate,
                                  endDate,
                                  medicineType,
                                  strength,
                                  unit,
                                  frequency,
                                  scheduleDetails);
                            },
                          ),
                          Text(
                            'S U M M A R Y',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.check,
                              color: Theme.of(context).primaryColorDark,
                              size: 20,
                            ),
                            onPressed: () {
                              saveMedicineAndEvent(
                                context,
                                ref,
                                petId,
                                medicineName,
                                startDate,
                                endDate,
                                medicineType,
                                strength,
                                unit,
                                frequency,
                                emoji,
                                scheduleDetails,
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Larger name on the left and emoji on the right
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    medicineName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Other details
                          _buildSummaryRow(context, 'Start Date',
                              DateFormat('dd-MM-yyyy').format(startDate)),
                          _buildSummaryRow(context, 'End Date',
                              DateFormat('dd-MM-yyyy').format(endDate)),
                          _buildSummaryRow(context, 'Type', medicineType),
                          _buildSummaryRow(
                              context, 'Strength', '$strength $unit'),
                          _buildSummaryRow(context, 'Frequency', frequency),
                          _buildScheduleSummaryRow(
                              context, 'Schedule', scheduleDetails),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildSummaryRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ],
    ),
  );
}

Widget _buildScheduleSummaryRow(
    BuildContext context, String label, String scheduleDetails) {
  final List<String> daysOfWeek = scheduleDetails.split(', ');

  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: daysOfWeek.map((day) {
            return Chip(
              label: Text(
                day,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 11),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            );
          }).toList(),
        ),
      ],
    ),
  );
}
