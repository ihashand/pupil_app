import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/eaten_meal_model.dart';
import 'package:pet_diary/src/models/food_recipe_model.dart';
import 'package:pet_diary/src/services/eaten_meal_service.dart';

void showRecipeDetails(
    BuildContext context, FoodRecipeModel recipe, String petId) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          TextEditingController dateController = TextEditingController(
            text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          );
          String mealType = 'Breakfast';

          void validateAndSave() async {
            final eatenMeal = EatenMealModel(
              id: '',
              date: DateFormat('dd-MM-yyyy').parse(dateController.text),
              mealType: mealType,
              name: recipe.name,
              kcal: recipe.totalKcal,
              fat: recipe.totalFat,
              carbs: recipe.totalCarbs,
              protein: recipe.totalProtein,
              grams: 100,
            );

            await ref
                .read(eatenMealServiceProvider)
                .addEatenMeal(petId, eatenMeal);

            Navigator.of(context).pop();
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
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          horizontal: 16, vertical: 10),
                      child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
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
                                    primary:
                                        Theme.of(context).colorScheme.secondary,
                                    onPrimary:
                                        Theme.of(context).primaryColorDark,
                                    onSurface:
                                        Theme.of(context).primaryColorDark,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).primaryColorDark,
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
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
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
                        items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
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
                      color: Theme.of(context).colorScheme.secondary,
                      height: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kcal: ${recipe.totalKcal}'),
                          Text('Protein: ${recipe.totalProtein}g'),
                          Text('Fat: ${recipe.totalFat}g'),
                          Text('Carbs: ${recipe.totalCarbs}g'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
