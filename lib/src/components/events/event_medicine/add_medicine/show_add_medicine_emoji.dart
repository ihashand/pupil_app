import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_medicine/add_medicine/show_add_medicine_schedule.dart';
import 'package:pet_diary/src/components/events/event_medicine/add_medicine/show_add_medicine_summary.dart';

void showAddMedicineEmoji(
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
    String scheduleDetails) {
  List<String> emojis = [
    '💊',
    '💉',
    '🧴',
    '🩹',
    '💧',
    '🧪',
    '🧬',
    '💡',
    '🍎',
    '🥑',
    '🧃',
    '🌟',
    '❤️',
    '🌼',
    '🐾',
    '⚡️',
    '🌀',
    '💥'
  ];
  String selectedEmoji = emojis[0];

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
                            showAddMedicineSchedule(context, ref, petId, '',
                                DateTime.now(), DateTime.now(), '', '', '');
                          },
                        ),
                        Text(
                          'S E L E C T  E M O J I',
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
                            Navigator.pop(context);
                            showAddMedicineSummary(
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
                                selectedEmoji,
                                scheduleDetails);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10.0,
                    children: emojis.map((emoji) {
                      bool isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEmoji = emoji;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).primaryColorDark,
                                    width: 2)
                                : null,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            );
          },
        ),
      );
    },
  );
}
