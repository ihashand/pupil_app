import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/extensions/string_extension.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/achievements_providers/achievements_provider.dart';
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
    final seasonalAchievement = ref.watch(seasonalAchievementProvider);

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

                      _collectAllPetsWithSteps(
                          pets, friends, ref, allPetsWithSteps);

                      // Sortowanie zwierząt po krokach
                      allPetsWithSteps
                          .sort((a, b) => b['steps'].compareTo(a['steps']));

                      return _buildPetList(
                        allPetsWithSteps.cast<Map<String, dynamic>>(),
                        context,
                        ref,
                        seasonalAchievement,
                      );
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

  void _collectAllPetsWithSteps(List<Pet> pets, List<Friend> friends,
      WidgetRef ref, List allPetsWithSteps) {
    for (var pet in pets) {
      final asyncWalks = ref.watch(eventWalksProvider(pet.id));
      final walksData = asyncWalks.whenData((walks) {
        final totalSteps =
            walks.fold(0.0, (sum, walk) => sum + walk!.steps).round();
        if (totalSteps >= 1000) {
          return {'pet': pet, 'steps': totalSteps};
        }
        return null;
      });
      if (walksData.value != null) {
        allPetsWithSteps.add(walksData.value);
      }
    }

    for (var friend in friends) {
      final friendPetsFuture =
          ref.read(petServiceProvider).getPetsFriendFuture(friend.friendId);
      friendPetsFuture.then((friendPets) {
        for (var pet in friendPets) {
          final asyncWalks = ref.watch(eventWalksProvider(pet.id));
          final walksData = asyncWalks.whenData((walks) {
            final totalSteps =
                walks.fold(0.0, (sum, walk) => sum + walk!.steps).round();
            if (totalSteps >= 1000) {
              return {'pet': pet, 'steps': totalSteps};
            }
            return null;
          });
          if (walksData.value != null) {
            allPetsWithSteps.add(walksData.value);
          }
        }
      });
    }
  }

  Widget _buildPetList(
      List<Map<String, dynamic>> petsWithSteps,
      BuildContext context,
      WidgetRef ref,
      AsyncValue<Achievement> seasonalAchievement) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: petsWithSteps.length,
      itemBuilder: (context, index) {
        final pet = petsWithSteps[index]['pet'];
        final steps = petsWithSteps[index]['steps'];

        return FutureBuilder(
          future: ref.read(appUserServiceProvider).getAppUserById(pet.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching user');
            } else {
              final user = snapshot.data;
              return Column(
                children: [
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('#${index + 1}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetProfileScreen(pet: pet),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 25,
                          ),
                        ),
                      ],
                    ),
                    title: _buildUserAndPetName(user!.username, pet.name),
                    trailing: _buildStepsDisplay(steps),
                  ),
                  seasonalAchievement.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) =>
                        const Text('Error fetching achievement'),
                    data: (achievement) {
                      return _buildProgressBar(
                          steps, achievement.stepsRequired, context);
                    },
                  ),
                  Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserAndPetName(String username, String petName) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Owner: ', style: TextStyle(fontSize: 11)),
                    Flexible(
                      child: Text(
                        username.capitalizeWord(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Pupil: ', style: TextStyle(fontSize: 11)),
                    Flexible(
                      child: Text(
                        petName.capitalizeWord(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildStepsDisplay(int steps) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$steps',
          style: TextStyle(
              fontSize: steps > 9999 ? 14 : 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          'STEPS',
          style: TextStyle(fontSize: 11, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
      int currentSteps, int totalSteps, BuildContext context) {
    final progressPercentage = (currentSteps / totalSteps);
    final displayedPercentage = (progressPercentage * 100)
        .toStringAsFixed(1); // Wyświetlamy cały postęp, np. 150%

    // Wybór koloru na podstawie cykli
    Color progressColor = Theme.of(context).colorScheme.inversePrimary;
    if (progressPercentage >= 1) {
      if (progressPercentage < 2) {
        progressColor = Colors.amber.shade100;
      } else if (progressPercentage < 3) {
        progressColor = Colors.amber.shade500;
      } else {
        progressColor = Colors.amber.shade900;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Stack(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, // Kolor tła paska
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            widthFactor:
                progressPercentage % 1, // Obsługuje pełny cykl i nadwyżkę
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                '$displayedPercentage%',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
