import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_care/event_type_card_care.dart';
import 'package:pet_diary/src/components/events/event_issue/event_type_card_issue.dart';
import 'package:pet_diary/src/components/events/event_mood/event_type_card_mood.dart';
import 'package:pet_diary/src/components/events/event_vaccines/event_type_card_vaccine.dart';
import 'package:pet_diary/src/components/events/event_water/event_type_card_water.dart';
import 'package:pet_diary/src/components/events/event_medications/event_type_card_medicine.dart';
import 'package:pet_diary/src/components/events/event_stool/event_type_card_stool.dart';
import 'package:pet_diary/src/components/events/event_temperature/event_type_card_temperature.dart';
import 'package:pet_diary/src/components/events/event_notes/event_type_card_notes.dart';
import 'package:pet_diary/src/components/events/event_food/others/event_type_card_food.dart';
import 'package:pet_diary/src/components/events/event_urine/event_type_card_urine.dart';
import 'package:pet_diary/src/components/events/event_weight/event_type_card_weight.dart';

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
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
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
            Divider(color: Theme.of(context).colorScheme.primary),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.89,
                    children: [
                      eventTypeCardWater(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardFood(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardMedicine(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardVaccines(
                        context,
                        ref,
                        petId,
                      ),
                      eventTypeCardMood(context, ref, petId, dateController),
                      eventTypeCardIssues(context, ref, petId, dateController),
                      eventTypeCardCare(context, ref, petId, dateController),
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
                      eventTypeCardWeight(
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
