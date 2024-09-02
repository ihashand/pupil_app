import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_eaten_meal_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_pet_settings_provider.dart';
import 'package:pet_diary/src/screens/event_food_screen.dart';
import 'package:pet_diary/src/tests/unit/services/events_services/event_food_eaten_meal_service.dart';
import 'package:table_calendar/table_calendar.dart';

void showMealDetails(BuildContext context, EventEatenMealModel meal,
    WidgetRef ref, String petId) {
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

              final selectedDate = ref.watch(selectedDateProvider);
              final eatenMealsAsyncValue =
                  ref.watch(eventFoodEatenMealsProvider(petId));

              double totalDailyKcal = 0.0;
              double totalDailyFat = 0.0;
              double totalDailyCarbs = 0.0;
              double totalDailyProtein = 0.0;

              eatenMealsAsyncValue.whenData((meals) {
                final mealsForSelectedDate = meals
                    .where((m) => isSameDay(m.date, selectedDate))
                    .toList();

                totalDailyKcal =
                    mealsForSelectedDate.fold(0.0, (sum, m) => sum + (m.kcal));
                totalDailyFat = mealsForSelectedDate.fold(
                    0.0, (sum, m) => sum + (m.fat ?? 0.0));
                totalDailyCarbs = mealsForSelectedDate.fold(
                    0.0, (sum, m) => sum + (m.carbs ?? 0.0));
                totalDailyProtein = mealsForSelectedDate.fold(
                    0.0, (sum, m) => sum + (m.protein ?? 0.0));
              });

              double calculateFill(double value, double dailyTotal) {
                return dailyTotal > 0 ? value / dailyTotal : 0.0;
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
                                          'Are you sure you want to delete ${meal.name}?',
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
                                                      eventFoodEatenMealServiceProvider)
                                                  .deleteEatenMeal(
                                                      petId, meal.id);
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
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    meal.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
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
                            controller: TextEditingController(
                                text: meal.grams.toString()),
                            decoration: InputDecoration(
                              labelText: 'Weight (g)',
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: TextField(
                            controller: TextEditingController(
                              text: DateFormat('dd-MM-yyyy').format(meal.date),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Date',
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: TextField(
                            controller:
                                TextEditingController(text: meal.mealType),
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
                            readOnly: true,
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.primary,
                          height: 32,
                        ),
                        // Nutritional information display
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 35.0, left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Calorie display
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
                                              meal.kcal, totalDailyKcal),
                                          strokeWidth: 10,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            calculateFill(meal.kcal,
                                                        totalDailyKcal) >=
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
                                            meal.kcal.toStringAsFixed(0),
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
                                            '${(meal.kcal / totalDailyKcal * 100).toStringAsFixed(1)}%',
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
                              // Carbohydrate display
                              Column(
                                children: [
                                  Text(
                                    '${((meal.carbs ?? 0) / totalDailyCarbs * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(meal.carbs ?? 0).toStringAsFixed(1)} g',
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
                              // Fat display
                              Column(
                                children: [
                                  Text(
                                    '${((meal.fat ?? 0) / totalDailyFat * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(meal.fat ?? 0).toStringAsFixed(1)} g',
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
                              // Protein display
                              Column(
                                children: [
                                  Text(
                                    '${((meal.protein ?? 0) / totalDailyProtein * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(meal.protein ?? 0).toStringAsFixed(1)} g',
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
