import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_date.dart';
import 'package:pet_diary/src/components/events/event_medications/add_medicine/show_add_medicine_strength.dart';

void showAddMedicineType(BuildContext context, WidgetRef ref, String petId,
    String medicineName, DateTime startDate, DateTime endDate) {
  List<String> medicineTypes = [
    'Capsule',
    'Tablet',
    'Liquid',
    'Aerosol',
    'Suppository',
    'Inhaler',
    'Cream',
    'Drops',
    'Ointment',
    'Foam',
    'Injection',
    'Other',
  ];
  String selectedType = medicineTypes[0];
  final TextEditingController otherTypeController = TextEditingController();

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
                            showAddMedicineDate(context, ref, petId, '');
                          },
                        ),
                        Text(
                          'S E L E C T  T Y P E',
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
                            String medicineType = selectedType == 'Other'
                                ? otherTypeController.text
                                : selectedType;

                            showAddMedicineStrength(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                              medicineType,
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
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Medicine Type',
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
                      value: selectedType,
                      items: medicineTypes
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (selectedType == 'Other')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: otherTypeController,
                        decoration: InputDecoration(
                          labelText: 'Other Medicine Type',
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
              ],
            );
          },
        ),
      );
    },
  );
}
