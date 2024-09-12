import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_care/event_type_card_care.dart';
import 'package:pet_diary/src/components/events/event_medications/event_type_card_medicine.dart';
import 'package:pet_diary/src/components/events/event_mood_and_issues/event_type_card_mood_and_issues.dart';
import 'package:pet_diary/src/components/events/event_stool/event_type_card_stool.dart';
import 'package:pet_diary/src/components/events/event_stool_and_urine/event_type_card_stool_and_urine.dart';
import 'package:pet_diary/src/components/events/event_temperature/event_type_card_temperature.dart';
import 'package:pet_diary/src/components/events/event_notes/event_type_card_notes.dart';
import 'package:pet_diary/src/components/events/event_food/functions/food_or_water.dart';
import 'package:pet_diary/src/components/events/event_urine/event_type_card_urine.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

void eventTypeSelection(BuildContext context, WidgetRef ref, String petId) {
  var titleController = TextEditingController();
  var contentTextController = TextEditingController();
  var temperatureController = TextEditingController();
  var dateController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.935,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).primaryColorDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Choose Event Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.primary),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 10,
                    children: [
                      eventTypeCard(context, 'D I E T',
                          'assets/images/health_event_card/dog_bowl_food.png',
                          () {
                        foodOrWater(context, ref, petId);
                      }),
                      eventTypeCardMedicine(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardCare(context, ref, petId, dateController),
                      eventTypeCardMoodAndIssues(
                          context, ref, petId, dateController),
                      eventTypeCardStool(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardUrine(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardTemperature(
                          context, temperatureController, ref, petId),
                      eventTypeCardNotes(context, titleController,
                          contentTextController, ref, petId),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
