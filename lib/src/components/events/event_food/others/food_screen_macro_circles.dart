import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_pet_settings_provider.dart';
import 'package:pet_diary/src/screens/event_food_screen.dart';
import 'package:pet_diary/src/tests/unit/services/events_services/event_food_eaten_meal_service.dart';
import 'package:pet_diary/src/components/events/event_food/others/food_screen_macro_circles_nutrient_circle.dart';
import 'package:pet_diary/src/components/events/event_food/functions/is_same_day.dart';

Widget foodScreenMacroCircles(
    BuildContext context, WidgetRef ref, String petId) {
  final petSettings = ref.watch(eventFoodPetSettingsProvider(petId));
  final eatenMealsAsyncValue = ref.watch(eventFoodEatenMealsProvider(petId));

  return eatenMealsAsyncValue.when(
    data: (meals) {
      final mealsForSelectedDate = meals
          .where(
              (meal) => isSameDay(meal.date, ref.watch(selectedDateProvider)))
          .toList();

      double totalKcal =
          mealsForSelectedDate.fold(0.0, (sum, meal) => sum + (meal.kcal));
      double totalFat = mealsForSelectedDate.fold(
          0.0, (sum, meal) => sum + (meal.fat ?? 0.0));
      double totalCarbs = mealsForSelectedDate.fold(
          0.0, (sum, meal) => sum + (meal.carbs ?? 0.0));
      double totalProtein = mealsForSelectedDate.fold(
          0.0, (sum, meal) => sum + (meal.protein ?? 0.0));

      return Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            nutrientCircle(
                context, 'Kcal', totalKcal, petSettings?.dailyKcal ?? 0.0),
            nutrientCircle(
                context, 'Fat', totalFat, petSettings?.fatPercentage ?? 0.0),
            nutrientCircle(context, 'Carbs', totalCarbs,
                petSettings?.carbsPercentage ?? 0.0),
            nutrientCircle(context, 'Protein', totalProtein,
                petSettings?.proteinPercentage ?? 0.0),
          ],
        ),
      );
    },
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => const SizedBox(),
  );
}
