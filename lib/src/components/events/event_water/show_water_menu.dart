import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_water_provider.dart';

void showWaterMenu(BuildContext context, WidgetRef ref, String petId) {
  var amountController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.37,
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'W A T E R',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () async {
                            String eventId = generateUniqueId();
                            EventWaterModel newWaterEvent = EventWaterModel(
                              id: eventId,
                              eventId: eventId,
                              petId: petId,
                              water:
                                  double.tryParse(amountController.text) ?? 0.0,
                              dateTime: selectedDateTime,
                            );

                            await ref
                                .read(eventWaterServiceProvider)
                                .addWater(newWaterEvent);

                            // ignore: use_build_context_synchronously
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
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: TextEditingController(
                                    text: DateFormat('dd-MM-yyyy')
                                        .format(selectedDateTime),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: selectedDateTime,
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
                                        picked != selectedDateTime) {
                                      selectedDateTime = picked;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                          child: TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: 'Amount (ml)',
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
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
