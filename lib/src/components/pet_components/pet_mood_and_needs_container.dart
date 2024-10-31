import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_care/event_type_card_care.dart';
import 'package:pet_diary/src/components/events/event_food_simple/show_food_simple.dart';
import 'package:pet_diary/src/components/events/event_issue/event_type_card_issue.dart';
import 'package:pet_diary/src/components/events/event_mood/event_type_card_mood.dart';
import 'package:pet_diary/src/components/events/event_notes/event_type_card_notes.dart';
import 'package:pet_diary/src/components/events/event_stool/event_type_card_stool.dart';
import 'package:pet_diary/src/components/events/event_temperature/event_type_card_temperature.dart';
import 'package:pet_diary/src/components/events/event_urine/event_type_card_urine.dart';
import 'package:pet_diary/src/components/events/event_vaccines/event_type_card_vaccine.dart';
import 'package:pet_diary/src/components/events/event_water/show_water_menu.dart';
import 'package:pet_diary/src/components/events/event_weight/event_type_card_weight.dart';
import 'package:pet_diary/src/components/events/walk/event_type_card_walk.dart';
import 'package:pet_diary/src/screens/medicine_screens/medicine_screen.dart';

class PetMoodAndNeedsContainer extends StatelessWidget {
  final String petName;
  final WidgetRef ref;
  final String? petId;
  final List<String>? petIds;

  const PetMoodAndNeedsContainer({
    super.key,
    required this.petName,
    required this.ref,
    this.petId,
    this.petIds,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentTextController = TextEditingController();
    TextEditingController temperatureController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How is $petName doing?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 100),
            Text(
              'Other needs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildEventItem(
                    context,
                    'Water',
                    'assets/images/events_type_cards_no_background/water_bowl.png',
                    () => showWaterMenu(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Food',
                    'assets/images/events_type_cards_no_background/food_bowl.png',
                    () => showFoodSimpleMenu(
                      context,
                      ref,
                      petId: petId,
                    ),
                  ),
                  _buildEventItem(
                    context,
                    'Medicine',
                    'assets/images/events_type_cards_no_background/pills.png',
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MedicineScreen(petId!),
                      ),
                    ),
                  ),
                  _buildEventItem(
                    context,
                    'Mood',
                    'assets/images/events_type_cards_no_background/heart.png',
                    () => showMoodOptions(
                      context,
                      ref,
                      petId: petId,
                      petIds: petIds,
                    ),
                  ),
                  _buildEventItem(
                    context,
                    'Vaccines',
                    'assets/images/events_type_cards_no_background/syringe.png',
                    () => showVaccineOptions(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Issues',
                    'assets/images/events_type_cards_no_background/issue.png',
                    () => showIssuesOptions(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Care',
                    'assets/images/events_type_cards_no_background/wanna.png',
                    () => showCareOptions(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Stool',
                    'assets/images/events_type_cards_no_background/poo.png',
                    () => showStoolModal(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Urine',
                    'assets/images/events_type_cards_no_background/piee.png',
                    () => showUrineModal(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Weight',
                    'assets/images/events_type_cards_no_background/weight.png',
                    () => showWeightModal(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Temperature',
                    'assets/images/events_type_cards_no_background/thermometr.png',
                    () => showTemperatureModal(
                        context, temperatureController, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Notes',
                    'assets/images/events_type_cards_no_background/notes.png',
                    () => showNotesModal(
                        context, titleController, contentTextController, ref,
                        petId: petId, petIds: petIds),
                  ),
                  _buildEventItem(
                    context,
                    'Walk DEVONLY',
                    'assets/images/events_type_cards_no_background/bed.png',
                    () => showWalkEventModal(context, ref,
                        petId: petId, petIds: petIds),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buduje pojedynczy element eventu z ikoną, podpisem i przypisaną akcją
  Widget _buildEventItem(BuildContext context, String label, String assetPath,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(assetPath),
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
