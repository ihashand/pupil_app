import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/note_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';
import 'package:pet_diary/src/screens/calendar_screen.dart';

class DetailsScreen extends ConsumerWidget {
  final String petId;

  const DetailsScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var pet = ref.watch(petRepositoryProvider).value?.getPetById(petId);

    var weight = ref
        .watch(weightRepositoryProvider)
        .value
        ?.getWeights()
        .where((w) => w.petId == pet!.id);

    var temperature = ref
        .watch(temperatureRepositoryProvider)
        .value
        ?.getTemperature()
        .where((w) => w.petId == pet!.id);

    var walk = ref
        .watch(walkRepositoryProvider)
        .value
        ?.getWalks()
        .where((w) => w.petId == pet!.id);

    var water = ref
        .watch(waterRepositoryProvider)
        .value
        ?.getWater()
        .where((w) => w.petId == pet!.id);

    var note = ref
        .watch(noteRepositoryProvider)
        .value
        ?.getNotes()
        .where((w) => w.petId == pet!.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: ExactAssetImage('assets/images/background_05.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${pet?.age} years old',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Name: ${pet?.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gender: ${pet?.gender}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (weight != null && weight.isNotEmpty)
                    Text(
                      'Weight: ${weight.last.weight} kg',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (temperature != null && temperature.isNotEmpty)
                    Text(
                      'Temperature: ${temperature.last.temperature} C',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (walk != null && walk.isNotEmpty)
                    Text(
                      'Walk: ${walk.last.walkDistance} km',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (water != null && water.isNotEmpty)
                    Text(
                      'Water: ${water.last.water} L',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (note != null && note.isNotEmpty)
                    Text(
                      'Note: ${note.last.note} ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalendarScreen(petId)),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
