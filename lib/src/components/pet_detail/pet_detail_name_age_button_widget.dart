import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/screens/events_screen.dart';

class PetDetailNameAgeButtonWidget extends ConsumerWidget {
  const PetDetailNameAgeButtonWidget({
    super.key,
    required this.buttonColor,
    required this.petId,
  });

  final Color buttonColor;
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Pet?>>(
        stream: ref.watch(petServiceProvider).getPets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error fetching pets');
          }
          if (snapshot.hasData) {
            final pet =
                snapshot.data!.where((element) => element!.id == petId).first;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        calculateAge(pet.age),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                  child: SizedBox(
                    height: 40,
                    width: 120,
                    child: FloatingActionButton(
                      backgroundColor: buttonColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventsScreen(petId)),
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
