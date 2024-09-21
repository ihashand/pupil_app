import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/events_screens/event_food_screen.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardFood(BuildContext context, WidgetRef ref, String petId) {
  return eventTypeCard(
    context,
    'F O O D',
    'assets/images/events_type_cards_no_background/food_bowl.png',
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodScreen(
            petId: petId,
          ),
        ),
      );
    },
  );
}
