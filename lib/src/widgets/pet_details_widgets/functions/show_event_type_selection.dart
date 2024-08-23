import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/build_event_type_card.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/build_event_type_card_notes.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/functions/show_feeding_or_water_menu.dart';

void showEventTypeSelection(BuildContext context, WidgetRef ref) {
  var titleController = TextEditingController();
  var contentTextController = TextEditingController();
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
                Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .primary), // Divider po nagłówku
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
                      buildEventTypeCardNotes(
                          context, titleController, contentTextController, ref),
                      buildEventTypeCard(context, 'Feeding',
                          'assets/images/health_event_card/dog_bowl_02.png',
                          () {
                        showFeedingOrWaterMenu(context, ref);
                      }),
                      buildEventTypeCard(context, 'Mesuring',
                          'assets/images/health_event_card/termometr.png', () {
                        // TODO: Implement navigation to Weight & Temperature screen
                      }),
                      buildEventTypeCard(context, 'Grooming',
                          'assets/images/health_event_card/hair_brush.png', () {
                        // TODO: Implement navigation to Grooming screen
                      }),
                      buildEventTypeCard(context, 'Mood & Mental',
                          'assets/images/health_event_card/dog_love.png', () {
                        // TODO: Implement navigation to Mood & Mental Health screen
                      }),
                      buildEventTypeCard(context, 'Physiologic',
                          'assets/images/health_event_card/poo.png', () {
                        // TODO: Implement navigation to Physiological Needs screen
                      }),
                      buildEventTypeCard(context, 'Medications',
                          'assets/images/health_event_card/pills.png', () {
                        // TODO: Implement navigation to Medications & Vaccines screen
                      }),
                      buildEventTypeCard(context, 'Others',
                          'assets/images/health_event_card/others.png', () {
                        // TODO: Implement navigation to Medications & Vaccines screen
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
