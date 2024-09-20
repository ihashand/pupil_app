import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_screen.dart';

class FriendsLeaderboard extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const FriendsLeaderboard({
    super.key,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);

    return Flexible(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 2),
              child: Text(
                'Leaderboard',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
            Expanded(
              child: asyncPets.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Error fetching pets'),
                data: (pets) {
                  final petsWithSteps = pets
                      .map((pet) {
                        final asyncWalks = ref.watch(eventWalksProvider);
                        return asyncWalks.when(
                          loading: () => null,
                          error: (err, stack) => null,
                          data: (walks) {
                            final totalSteps = walks
                                .where((walk) => walk!.petId == pet.id)
                                .fold(0.0, (sum, walk) => sum + walk!.steps)
                                .round(); // Usunięcie miejsc po przecinku
                            return {'pet': pet, 'steps': totalSteps};
                          },
                        );
                      })
                      .whereType<Map<String, dynamic>>()
                      .toList();

                  petsWithSteps
                      .sort((a, b) => b['steps'].compareTo(a['steps']));

                  if (petsWithSteps.length < 3) {
                    return Column(
                      children: [
                        Expanded(
                          child: _buildPetList(petsWithSteps, context),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'You don\'t have enough friends!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Add more friends to compete with them in steps.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FriendsScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Add Friends',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Zwykły widok, gdy liczba zwierzaków wynosi 3 lub więcej
                  return _buildPetList(petsWithSteps, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funkcja do budowania listy zwierzaków
  Widget _buildPetList(
      List<Map<String, dynamic>> petsWithSteps, BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: petsWithSteps.length,
      itemBuilder: (context, index) {
        final user = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
        final steps = petsWithSteps[index]['steps'];
        final petName = petsWithSteps[index]['pet'].name;

        return Column(
          children: [
            ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${index + 1}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4), // Zmniejszony odstęp
                  CircleAvatar(
                    backgroundImage:
                        AssetImage(petsWithSteps[index]['pet'].avatarImage),
                    radius: 25,
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Owner: ',
                                style: TextStyle(fontSize: 11),
                              ),
                              Flexible(
                                child: Text(
                                  user,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Pupil: ',
                                style: TextStyle(fontSize: 11),
                              ),
                              Flexible(
                                child: Text(
                                  petName,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$steps',
                    style: TextStyle(
                      fontSize: steps > 9999
                          ? 14
                          : 16, // Zmniejszony rozmiar dla > 9999 kroków
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'STEPS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: const Color(0xff68a2b6).withOpacity(0.2),
            ),
          ],
        );
      },
    );
  }
}
