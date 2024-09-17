import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_water/show_water_menu.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardWater(BuildContext context, WidgetRef ref, String petId) {
  return eventTypeCard(
    context,
    'W A T E R',
    'assets/images/events_type_cards_no_background/water_bowl.png',
    () {
      showWaterMenu(context, ref, petId);
    },
  );
}
