import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/screens/health_screen.dart';

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

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      calculateAge(pet.age),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: SizedBox(
                  height: 40,
                  width: 120,
                  child: FloatingActionButton(
                    backgroundColor: buttonColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthScreen(petId),
                        ),
                      );
                    },
                    child: Text(
                      'H E A L T H',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
