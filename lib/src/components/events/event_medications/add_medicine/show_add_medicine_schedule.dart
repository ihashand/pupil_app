import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_emoji.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_strength.dart';

void showAddMedicineSchedule(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType,
    String strength,
    String unit) {
  final frequencyController = TextEditingController();
  String scheduleOption = 'Daily';
  String scheduleDetails = 'Daily';
  Map<String, bool> daysOfWeek = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

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
            return Column(
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
                            showAddMedicineStrength(context, ref, petId, '',
                                DateTime.now(), DateTime.now(), '');
                          },
                        ),
                        Text(
                          'MEDICINE SCHEDULE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColorDark,
                            size: 20,
                          ),
                          onPressed: () {
                            final frequency = frequencyController.text;

                            if (frequency.isEmpty) {
                              _showDialog(
                                context,
                                'Frequency Error',
                                'Please fill in the frequency field.',
                              );
                            } else if (int.tryParse(frequency) == null) {
                              _showDialog(
                                context,
                                'Frequency Error',
                                'Please enter a valid number.',
                              );
                            } else if (int.parse(frequency) > 100) {
                              _showDialog(
                                context,
                                'Frequency Error',
                                'Frequency cannot exceed 100 times per day.',
                              );
                            } else {
                              if (scheduleOption ==
                                  'Selected Days of the Week') {
                                scheduleDetails = daysOfWeek.entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .join(', ');
                                if (scheduleDetails.isEmpty) {
                                  scheduleDetails = 'No days selected';
                                }
                              }

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
                                frequencyController.text,
                                scheduleDetails,
                              );
                            }
                          },
                        ),
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 15, 16, 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: frequencyController,
                              decoration: InputDecoration(
                                labelText: 'How many times per day?',
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
                              keyboardType: TextInputType.number,
                              cursorColor: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: scheduleOption,
                              items: [
                                'Daily',
                                'Every X Days',
                                'Every X Weeks',
                                'Every X Months',
                                'Selected Days of the Week',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  scheduleOption = newValue!;
                                  if (scheduleOption !=
                                      'Selected Days of the Week') {
                                    scheduleDetails = scheduleOption;
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Schedule',
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
                            ),
                          ),
                        ),
                        if (scheduleOption == 'Every X Days' ||
                            scheduleOption == 'Every X Weeks' ||
                            scheduleOption == 'Every X Months')
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 15),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: scheduleOption == 'Every X Days'
                                    ? 'Enter number of days'
                                    : scheduleOption == 'Every X Weeks'
                                        ? 'Enter number of weeks'
                                        : 'Enter number of months',
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
                              keyboardType: TextInputType.number,
                              cursorColor: Theme.of(context).primaryColorDark,
                              onChanged: (value) {
                                scheduleDetails =
                                    'Every $value ${scheduleOption.substring(6).toLowerCase()}';
                              },
                            ),
                          ),
                        if (scheduleOption == 'Selected Days of the Week')
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 15),
                            child: Column(
                              children: daysOfWeek.keys.map((String day) {
                                return CheckboxListTile(
                                  title: Text(day),
                                  value: daysOfWeek[day],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      daysOfWeek[day] = value!;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void _showDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
