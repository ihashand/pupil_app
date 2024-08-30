import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/screens/food_screen.dart';
import 'package:pet_diary/src/services/eaten_meal_service.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/build_nutrient_circle.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/_is_same_day.dart';

Widget buildMacroCircles(BuildContext context, WidgetRef ref, String petId) {
  final petSettings = ref.watch(petSettingsProvider(petId));
  final eatenMealsAsyncValue = ref.watch(eatenMealsProvider(petId));

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
            buildNutrientCircle(
                context, 'Kcal', totalKcal, petSettings?.dailyKcal ?? 0.0),
            buildNutrientCircle(
                context, 'Fat', totalFat, petSettings?.fatPercentage ?? 0.0),
            buildNutrientCircle(context, 'Carbs', totalCarbs,
                petSettings?.carbsPercentage ?? 0.0),
            buildNutrientCircle(context, 'Protein', totalProtein,
                petSettings?.proteinPercentage ?? 0.0),
          ],
        ),
      );
    },
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => const SizedBox(),
  );
}
