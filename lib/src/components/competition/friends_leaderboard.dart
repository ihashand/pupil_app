import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';

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

    return AnimatedSize(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      child: Container(
        height: 410,
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
            asyncPets.when(
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
                              .fold(0.0, (sum, walk) => sum + walk!.steps);
                          return {'pet': pet, 'steps': totalSteps};
                        },
                      );
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();

                petsWithSteps.sort((a, b) => b['steps'].compareTo(a['steps']));

                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: petsWithSteps.length,
                    itemBuilder: (context, index) {
                      final user =
                          FirebaseAuth.instance.currentUser?.displayName ??
                              'User';
                      final steps = petsWithSteps[index]['steps'];
                      final petName = petsWithSteps[index]['pet'].name;

                      return Column(
                        children: [
                          ListTile(
                            leading: Text(
                              '#${index + 1}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                      petsWithSteps[index]['pet'].avatarImage),
                                  radius: 25,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text('Owner: ',
                                                style: TextStyle(fontSize: 11)),
                                            Text(user,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text('Pupil: ',
                                                style: TextStyle(fontSize: 11)),
                                            Text('$petName',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$steps',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('Steps',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                          Divider(
                              color: const Color(0xff68a2b6).withOpacity(0.2)),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
