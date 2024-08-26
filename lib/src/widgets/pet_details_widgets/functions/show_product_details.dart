import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';

void showProductDetails(
    BuildContext context, ProductModel product, String petId) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final petSettingsFuture = ref.watch(petSettingsStreamProvider(petId));

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
              String selectedUnit = 'g'; // Domyślnie gramy

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

              void validateAndSave() {
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
                  // Logika zapisu posiłku
                }
              }

              double calculateFill(double kcal) {
                double fillPercentage = kcal / settings.dailyKcal;
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
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16, top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: gramsController,
                                  keyboardType: TextInputType.numberWithOptions(
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
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16, top: 10, bottom: 10),
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
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16, top: 10, bottom: 10),
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
                        // Sekcja danych
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 35.0, left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Kcal w kółku z kreską
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
                                              product.kcal * grams / 100),
                                          strokeWidth: 10,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            calculateFill(product.kcal *
                                                        grams /
                                                        100) >=
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
                              // Węglowodany
                              Column(
                                children: [
                                  Text(
                                    '${((product.carbs ?? 0) / grams * 100).toStringAsFixed(1)}%',
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
                                    'Węglowodany',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Tłuszcz
                              Column(
                                children: [
                                  Text(
                                    '${((product.fat ?? 0) / grams * 100).toStringAsFixed(1)}%',
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
                                    'Tłuszcz',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Białko
                              Column(
                                children: [
                                  Text(
                                    '${((product.protein ?? 0) / grams * 100).toStringAsFixed(1)}%',
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
                                    'Białko',
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
