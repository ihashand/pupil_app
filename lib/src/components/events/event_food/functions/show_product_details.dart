import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/others/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_pet_settings_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';
import 'package:pet_diary/src/services/events_services/event_food_eaten_meal_service.dart';
import 'package:pet_diary/src/models/events_models/event_eaten_meal_model.dart';

void showProductDetails(
    BuildContext context, ProductModel product, String petId) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final petSettingsFuture =
              ref.watch(eventFoodPetSettingsStreamProvider(petId));

          return petSettingsFuture.when(
            data: (settings) {
              if (settings == null) {
                return Center(
                  child: Text(
                    'No settings found for this pet.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              TextEditingController gramsController =
                  TextEditingController(text: '100');
              TextEditingController dateController = TextEditingController(
                text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
              );
              String mealType = settings.mealTypes.isNotEmpty
                  ? settings.mealTypes.first
                  : 'Breakfast';
              double grams = 100.0;
              String selectedUnit = 'g';

              void updateValues() {
                double factor = double.tryParse(gramsController.text) ?? 100.0;
                if (selectedUnit == 'kg') {
                  factor *= 1000;
                }
                grams = factor;
              }

              void handleInput(String value, StateSetter setState) {
                value = value.replaceAll(',', '.');
                if (selectedUnit == 'g' || selectedUnit == 'ml') {
                  if (value.length > 6) {
                    value = value.substring(0, 6);
                  }
                } else if (selectedUnit == 'kg') {
                  if (value.length > 3) {
                    value = value.substring(0, 3);
                  }
                }
                setState(() {
                  gramsController.text = value;
                  gramsController.selection = TextSelection.fromPosition(
                    TextPosition(offset: gramsController.text.length),
                  );
                  updateValues();
                });
              }

              void validateAndSave() async {
                if (grams > 5000) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Posiłek nie może być większy niż 5 kg.',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                } else {
                  final eatenMeal = EventEatenMealModel(
                    id: '',
                    date: DateFormat('dd-MM-yyyy').parse(dateController.text),
                    mealType: mealType,
                    name: product.name,
                    kcal: product.kcal * grams / 100,
                    fat: (product.fat ?? 0) * grams / 100,
                    carbs: (product.carbs ?? 0) * grams / 100,
                    protein: (product.protein ?? 0) * grams / 100,
                    grams: grams,
                  );

                  await ref
                      .read(eventFoodEatenMealServiceProvider)
                      .addEatenMeal(petId, eatenMeal);

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              }

              double calculateFill(double kcal, double dailyKcal) {
                double fillPercentage = kcal / dailyKcal;
                return fillPercentage.clamp(0.0, 1.0);
              }

              return StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Confirm Deletion',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete ${product.name}?',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      eventProductServiceProvider)
                                                  .removeProductFromAll(
                                                      product.id);

                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              Flexible(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: validateAndSave,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: gramsController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Weight',
                                    labelStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      handleInput(value, setState),
                                ),
                              ),
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                value: selectedUnit,
                                items: ['g', 'kg', 'ml']
                                    .map((unit) => DropdownMenuItem(
                                          value: unit,
                                          child: Text(unit),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUnit = value!;
                                    updateValues();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: 'Select Date',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
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
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        onPrimary:
                                            Theme.of(context).primaryColorDark,
                                        onSurface:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  dateController.text = DateFormat('dd-MM-yyyy')
                                      .format(pickedDate);
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: DropdownButtonFormField<String>(
                            value: mealType,
                            decoration: InputDecoration(
                              labelText: 'Meal Type',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
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
                            items: settings.mealTypes
                                .map((meal) => DropdownMenuItem(
                                      value: meal,
                                      child: Text(meal),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                mealType = value!;
                              });
                            },
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.primary,
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 35.0, left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        height: 90,
                                        child: CircularProgressIndicator(
                                          value: calculateFill(
                                              product.kcal * grams / 100,
                                              settings.dailyKcal),
                                          strokeWidth: 10,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            calculateFill(
                                                        product.kcal *
                                                            grams /
                                                            100,
                                                        settings.dailyKcal) >=
                                                    1.0
                                                ? Colors.purple
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        child: Container(
                                          width: 3,
                                          height: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            (product.kcal * grams / 100)
                                                .toStringAsFixed(0),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'kcal',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${(product.kcal * grams / 100 / settings.dailyKcal * 100).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${((product.carbs ?? 0) * grams / 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(product.carbs ?? 0) * grams / 100} g',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Carbs',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${((product.fat ?? 0) * grams / 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(product.fat ?? 0) * grams / 100} g',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Fat',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${((product.protein ?? 0) * grams / 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(product.protein ?? 0) * grams / 100} g',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Proteins',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error loading settings',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
