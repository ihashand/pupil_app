import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/extensions/string_extension.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/others_providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/friend_provider.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_pet_profile_screen.dart';

class CompetitionFriendsLeaderboard extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const CompetitionFriendsLeaderboard({
    super.key,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);
    final friendsAsyncValue = ref.watch(friendsStreamProvider);

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
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 5),
              child: Text(
                'Leaderboard',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark),
              ),
            ),
            Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
            Expanded(
              child: asyncPets.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Error fetching pets'),
                data: (pets) {
                  return friendsAsyncValue.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => const Text('Error fetching friends'),
                    data: (friends) {
                      final allPetsWithSteps = [];

                      // Dodawanie zwierząt użytkownika
                      for (var pet in pets) {
                        final asyncWalks =
                            ref.watch(eventWalksProvider(pet.id));
                        final walksData = asyncWalks.whenData((walks) {
                          final totalSteps = walks
                              .where((walk) => walk!.petId == pet.id)
                              .fold(0.0, (sum, walk) => sum + walk!.steps)
                              .round();

                          if (totalSteps >= 1000) {
                            return {'pet': pet, 'steps': totalSteps};
                          }
                          return null;
                        });

                        if (walksData.value != null) {
                          allPetsWithSteps.add(walksData.value);
                        }
                      }

                      // Dodawanie zwierząt znajomych
                      for (var friend in friends) {
                        final friendPetsFuture = ref
                            .read(petServiceProvider)
                            .getPetsFriendFuture(friend.friendId);

                        return FutureBuilder<List<Pet>>(
                          future: friendPetsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Error fetching friend pets');
                            } else if (snapshot.hasData) {
                              var friendPets = snapshot.data ?? [];

                              // Dodawanie zwierząt znajomych do listy
                              for (var pet in friendPets) {
                                final asyncWalks =
                                    ref.watch(eventWalksProvider(pet.id));
                                final walksData = asyncWalks.whenData((walks) {
                                  final totalSteps = walks
                                      .where((walk) => walk!.petId == pet.id)
                                      .fold(
                                          0.0, (sum, walk) => sum + walk!.steps)
                                      .round();

                                  if (totalSteps >= 1000) {
                                    return {'pet': pet, 'steps': totalSteps};
                                  }
                                  return null;
                                });

                                if (walksData.value != null) {
                                  allPetsWithSteps.add(walksData.value);
                                }
                              }

                              // Sortowanie zwierząt po krokach
                              allPetsWithSteps.sort(
                                  (a, b) => b['steps'].compareTo(a['steps']));

                              return _buildPetList(
                                  allPetsWithSteps.cast<Map<String, dynamic>>(),
                                  context,
                                  ref);
                            } else {
                              return const Text(
                                  'No pets found for this friend');
                            }
                          },
                        );
                      }

                      // Fallback in case no friends
                      return const Text('No friends found');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetList(List<Map<String, dynamic>> petsWithSteps,
      BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: petsWithSteps.length,
      itemBuilder: (context, index) {
        final pet = petsWithSteps[index]['pet'];
        final steps = petsWithSteps[index]['steps'];
        String petName = petsWithSteps[index]['pet'].name;

        return FutureBuilder(
          future: ref.read(appUserServiceProvider).getAppUserById(pet.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching user');
            } else {
              final user = snapshot.data;
              return GestureDetector(
                onTap: () {
                  // Nawigacja do profilu zwierzaka po kliknięciu na ListTile
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetProfileScreen(pet: pet),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${index + 1}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
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
                                          user!.username.capitalizeWord(),
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
                                          petName.capitalizeWord(),
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
                              fontSize: steps > 9999 ? 14 : 16,
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
                ),
              );
            }
          },
        );
      },
    );
  }
}
