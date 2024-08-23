import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/food_screen.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/functions/show_water_menu.dart';

void showFeedingOrWaterMenu(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select an Option'),
        content: const Text(
            'Would you like to add a feeding event or a water event?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Feeding',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodScreen()),
              );
            },
          ),
          TextButton(
            child: Text('Water',
                style: TextStyle(color: Theme.of(context).primaryColorDark)),
            onPressed: () {
              Navigator.of(context).pop();
              showWaterMenu(context, ref);
            },
          ),
        ],
      );
    },
  );
}
