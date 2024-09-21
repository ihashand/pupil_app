import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_schedule.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_type.dart';

void showAddMedicineStrength(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType) {
  final strengthController = TextEditingController();
  List<String> units = ['mg', 'mcg', 'g', 'ml', '%'];
  String selectedUnit = units[0];

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
                            showAddMedicineType(context, ref, petId, '',
                                DateTime.now(), DateTime.now());
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              'S T R E N G T H',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            Text(
                              'O P T I O N A L',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColorDark,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showAddMedicineSchedule(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                              medicineType,
                              strengthController.text,
                              selectedUnit,
                            );
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: strengthController,
                              decoration: InputDecoration(
                                labelText: 'Medicine Strength',
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              cursorColor: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Unit',
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
                              value: selectedUnit,
                              items: units
                                  .map((unit) => DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(unit),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedUnit = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
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
