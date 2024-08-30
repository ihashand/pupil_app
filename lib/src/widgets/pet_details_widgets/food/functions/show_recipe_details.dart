import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/food_recipe_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/food_recipe_provider.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/services/eaten_meal_service.dart';
import 'package:pet_diary/src/models/eaten_meal_model.dart';

void showRecipeDetails(
    BuildContext context, FoodRecipeModel recipe, String petId) {
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
              String selectedUnit = 'g'; // Default unit is grams
              bool showDetails = false;

              void updateValues() {
                double factor = double.tryParse(gramsController.text) ?? 100.0;
                if (selectedUnit == 'kg') {
                  factor *= 1000;
                }
                grams = factor;
              }

              void handleInput(String value, StateSetter setState) {
                value = value.replaceAll(',', '.');
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Weight Limit Exceeded',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark),
                        ),
                        content: Text(
                          'The meal cannot be heavier than 5 kg.',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  final eatenMeal = EatenMealModel(
                    id: '',
                    date: DateFormat('dd-MM-yyyy').parse(dateController.text),
                    mealType: mealType,
                    name: recipe.name,
                    kcal: recipe.totalKcal * grams / 100,
                    fat: recipe.totalFat * grams / 100,
                    carbs: recipe.totalCarbs * grams / 100,
                    protein: recipe.totalProtein * grams / 100,
                    grams: grams,
                  );

                  await ref
                      .read(eatenMealServiceProvider)
                      .addEatenMeal(petId, eatenMeal);

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
                    child: SingleChildScrollView(
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
                                            'Are you sure you want to delete ${recipe.name}?',
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
                                                        foodRecipeServiceProvider)
                                                    .removeRecipeFromAll(
                                                        recipe.id);

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
                                    recipe.name,
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
                                horizontal: 16, vertical: 5),
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
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
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
                                horizontal: 16, vertical: 5),
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
                                  builder:
                                      (BuildContext context, Widget? child) {
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
                                    dateController.text =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                  });
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
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
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDetails = !showDetails;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    showDetails
                                        ? 'Hide Details'
                                        : 'Show Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  Icon(
                                    showDetails
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (showDetails) ...[
                            if (recipe.preparationTime != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${recipe.preparationTime} min',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (recipe.ingredients.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ingredients:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    ...recipe.ingredients.map(
                                      (ingredient) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Text(
                                          '- $ingredient',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (recipe.preparationSteps.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Preparation steps:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    ...recipe.preparationSteps.map(
                                      (step) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Text(
                                          '- $step',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          Divider(
                            color: Theme.of(context).colorScheme.primary,
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 35.0, left: 16, right: 20, top: 5),
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
                                                recipe.totalKcal * grams / 100,
                                                settings.dailyKcal),
                                            strokeWidth: 10,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              calculateFill(
                                                          recipe.totalKcal *
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
                                              (recipe.totalKcal * grams / 100)
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
                                              '${(recipe.totalKcal * grams / 100 / settings.dailyKcal * 100).toStringAsFixed(2)}%',
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
                                      '${(recipe.totalCarbs * grams / 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(recipe.totalCarbs * grams / 100).toStringAsFixed(1)} g',
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
                                      '${(recipe.totalFat * grams / 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(recipe.totalFat * grams / 100).toStringAsFixed(1)} g',
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
                                      '${(recipe.totalProtein * grams / 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(recipe.totalProtein * grams / 100).toStringAsFixed(1)} g',
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
