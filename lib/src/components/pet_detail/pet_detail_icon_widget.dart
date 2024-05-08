import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

class PetDetailIconWidget extends ConsumerWidget {
  const PetDetailIconWidget({
    super.key,
    required this.weight,
    required this.petId,
  });

  final String weight;
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

            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (pet!.gender == 'Male')
                        const Icon(
                          Icons.male,
                          size: 40,
                        ),
                      if (pet.gender == 'Female')
                        const Icon(
                          Icons.female,
                          size: 40,
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Gender',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(pet.gender,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '🎂',
                        style: TextStyle(fontSize: 35),
                      ),
                      const Text(
                        'Birth date',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(pet.age,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '🐶',
                        style: TextStyle(fontSize: 35),
                      ),
                      const Text(
                        'Breed',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(pet.breed,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '⚖️',
                        style: TextStyle(fontSize: 35),
                      ),
                      const Text(
                        'Weight',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        '$weight kg',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
