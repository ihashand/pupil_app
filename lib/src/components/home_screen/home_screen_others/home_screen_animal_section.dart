import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_cards/animal_card.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/screens/pet_screens/pet_add_new_screen.dart';

class HomeScreenAnimalSection extends ConsumerWidget {
  const HomeScreenAnimalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);
    final asyncWalks = ref.watch(eventWalksProviderStream);

    return asyncWalks.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => const Text('Error fetching walks'),
      data: (walks) {
        return asyncPets.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => const Text('Error fetching pets'),
          data: (pets) {
            return SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length + 1,
                itemBuilder: (context, index) {
                  if (index < pets.length) {
                    final currentPet = pets[index];
                    final petWalks = walks
                        .where((walk) =>
                            walk != null && walk.petId == currentPet.id)
                        .cast<EventWalkModel>()
                        .toList();

                    return AnimalCard(
                      pet: currentPet,
                      walks: petWalks,
                      key: ValueKey(currentPet.id),
                    );
                  } else {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AddPetScreen(ref: ref),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add,
                            size: 70, color: Color(0xff68a2b6)),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
