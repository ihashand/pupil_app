import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';

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
          // Sprawdzenie, czy lista zawiera petId
          final petList =
              snapshot.data!.where((element) => element!.id == petId).toList();
          if (petList.isEmpty) {
            // Obsługa przypadku, gdy zwierzę zostało usunięte
            return const Center(
              child: Text(
                'Pet not found or has been deleted',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Ponieważ `petList` ma co najmniej jeden element, można użyć `first`
          final pet = petList.first!;

          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 2,
                    ),
                    if (pet.gender == 'Male')
                      const Icon(
                        Icons.male,
                        size: 40,
                      ),
                    if (pet.gender == 'Female')
                      const Icon(
                        Icons.female,
                        size: 40,
                      ),
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 9),
                    ),
                    Text(pet.gender,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '🎂',
                      style: TextStyle(fontSize: 30),
                    ),
                    const Text(
                      'Birth date',
                      style: TextStyle(fontSize: 9),
                    ),
                    Text(pet.age,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '🐶',
                      style: TextStyle(fontSize: 30),
                    ),
                    const Text(
                      'Breed',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(pet.breed,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '⚖️',
                      style: TextStyle(fontSize: 30),
                    ),
                    const Text(
                      'Weight',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      '$weight kg',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
