import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_water_model.dart';
import 'package:pet_diary/src/providers/event_water_provider.dart';

void showWaterMenu(BuildContext context, WidgetRef ref) {
  var amountController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).primaryColorDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Add Water Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text('Date: ${selectedDateTime.toLocal()}'.split(' ')[0]),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != selectedDateTime) {
                            selectedDateTime = picked;
                          }
                        },
                        child: const Text('Select date'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount (ml)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      String eventId = generateUniqueId();
                      EventWaterModel newWaterEvent = EventWaterModel(
                        id: eventId,
                        eventId: eventId,
                        petId: '', // Wstaw właściwy petId
                        water: double.tryParse(amountController.text) ?? 0.0,
                        dateTime: selectedDateTime,
                      );

                      await ref
                          .read(eventWaterServiceProvider)
                          .addWater(newWaterEvent);

                      Navigator.of(context).pop();
                    },
                    child: const Text('SAVE'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
