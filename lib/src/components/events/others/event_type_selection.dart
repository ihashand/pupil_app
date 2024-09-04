import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_care/event_type_card_care.dart';
import 'package:pet_diary/src/components/events/event_mood_and_mental/event_mood_and_mental.dart';
import 'package:pet_diary/src/components/events/event_temperature/event_type_card_temperature.dart';
import 'package:pet_diary/src/components/events/event_notes/event_type_card_notes.dart';
import 'package:pet_diary/src/components/events/event_food/functions/food_or_water_alert_dialog.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

void eventTypeSelection(BuildContext context, WidgetRef ref, String petId) {
  var titleController = TextEditingController();
  var contentTextController = TextEditingController();
  var temperatureController = TextEditingController();
  var dateController =
      TextEditingController(); // Kontroler daty dla Mood & Mental

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        builder: (context, scrollController) {
          return Container(
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
                  child: GridView.count(
                    controller: scrollController,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    children: [
                      eventTypeCardNotes(context, titleController,
                          contentTextController, ref, petId),
                      eventTypeCard(context, 'Feeding',
                          'assets/images/health_event_card/dog_bowl_02.png',
                          () {
                        foodOrWaterAlertDialog(context, ref, petId);
                      }),
                      eventTypeCardTemperature(
                          context, temperatureController, ref, petId),
                      eventTypeCardCare(context, ref, petId, dateController),
                      eventTypeCardMoodAndMental(context, ref, petId,
                          dateController), // Dodano kartę Mood & Mental
                      eventTypeCard(context, 'Physiologic',
                          'assets/images/health_event_card/poo.png', () {
                        // TODO: Implement navigation to Physiological Needs screen
                      }),
                      eventTypeCard(context, 'Medications',
                          'assets/images/health_event_card/pills.png', () {
                        // TODO: Implement navigation to Medications & Vaccines screen
                      }),
                      eventTypeCard(context, 'Others',
                          'assets/images/health_event_card/others.png', () {
                        // TODO: Implement navigation to Others screen
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
