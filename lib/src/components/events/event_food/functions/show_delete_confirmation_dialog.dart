import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_eaten_meal_model.dart';
import 'package:pet_diary/services/events_services/event_food_eaten_meal_service.dart';

void showDeleteConfirmationDialog(BuildContext context, WidgetRef ref,
    EventEatenMealModel meal, String petId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Confirm Deletion',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        content: Text(
          'Are you sure you want to delete ${meal.name}?',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            onPressed: () {
              ref
                  .read(eventFoodEatenMealServiceProvider)
                  .deleteEatenMeal(petId, meal.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
