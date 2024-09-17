import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/screens/medicine_screens/medicine_screen.dart';

Widget eventTypeCardMedicine(
    BuildContext context, WidgetRef ref, String petId) {
  return eventTypeCard(
    context,
    'M E D I C I N E',
    'assets/images/events_type_cards_no_background/pills.png',
    () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MedicineScreen(petId),
        ),
      );
    },
  );
}
