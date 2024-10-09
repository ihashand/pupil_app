import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/competition/achievement_details_dialog.dart';
import 'package:pet_diary/src/components/competition/achievement_section.dart';
import 'package:pet_diary/src/components/competition/competition_friends_leaderboard.dart';
import 'package:pet_diary/src/providers/achievements_providers/achievements_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/others_providers/walk_state_provider.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_screen.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_in_progress_screen.dart';
import 'package:shimmer/shimmer.dart';

class WalkCompetitionScreen extends ConsumerStatefulWidget {
  const WalkCompetitionScreen({super.key});

  @override
  createState() => _WalkCompetitionScreenState();
}

class _WalkCompetitionScreenState extends ConsumerState<WalkCompetitionScreen> {
  late TextEditingController searchController;
  String searchQuery = '';
  List<int> selectedPetIndexes = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _selectDog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).colorScheme.primary, // Kolor tła wyboru piesków
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final asyncPets = ref.watch(petsProvider);

            return asyncPets.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Error fetching pets'),
              data: (pets) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 20,
                              top: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select pet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                TextButton(
                                  onPressed: selectedPetIndexes.isNotEmpty
                                      ? () {
                                          final selectedPets =
                                              selectedPetIndexes
                                                  .map((index) => pets[index])
                                                  .toList();

                                          ref
                                              .read(activeWalkPetsProvider
                                                  .notifier)
                                              .state = selectedPets;

                                          Navigator.pop(context);

                                          final walkNotifier =
                                              ref.read(walkProvider.notifier);
                                          walkNotifier.stopWalk();
                                          walkNotifier.startWalk();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WalkInProgressScreen(
                                                pets: selectedPets,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    'Start Walk',
                                    style: TextStyle(
                                      color: selectedPetIndexes.isNotEmpty
                                          ? Theme.of(context).primaryColorDark
                                          : Colors.grey.withOpacity(0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Theme.of(context).colorScheme.surface),
                          Container(
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // Kolor tła wyboru piesków
                            child: pets.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          'No dogs available to display.',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Add a dog to start a walk.',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: pets
                                        .map(
                                          (pet) => GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                int index = pets.indexOf(pet);
                                                if (selectedPetIndexes
                                                    .contains(index)) {
                                                  selectedPetIndexes
                                                      .remove(index);
                                                } else {
                                                  selectedPetIndexes.add(index);
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedPetIndexes.contains(
                                                            pets.indexOf(pet))
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .secondary
                                                        : Colors.transparent,
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: AssetImage(
                                                      pet.avatarImage),
                                                ),
                                                title: Text(pet.name),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAchievementDetails(BuildContext context, String petId) {
    final achievementProvider = ref.watch(seasonalAchievementProvider);
    final petStepsProvider = ref.watch(petStepsProviderFamily(petId));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return achievementProvider.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => const Text('Error fetching achievements'),
          data: (achievement) {
            return petStepsProvider.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Error fetching steps'),
              data: (currentSteps) {
                return AchievementDetailsDialog(
                  achievementName: achievement.name,
                  currentSteps: currentSteps,
                  totalSteps: achievement.stepsRequired,
                  assetPath: achievement.avatarUrl,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walkState = ref.watch(walkProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark,
          size: 20,
        ),
        title: Text(
          'C O M P E T I T I O N',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendsScreen(),
                ),
              );
            },
            color: Theme.of(context).primaryColorDark,
            iconSize: 20,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: Theme.of(context).colorScheme.surface,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 10,
            bottom: 10,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surface,
              highlightColor: Theme.of(context).colorScheme.primary,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: ElevatedButton(
                    onPressed: walkState.isWalking
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WalkInProgressScreen(
                                    pets: ref.read(activeWalkPetsProvider)),
                              ),
                            );
                          }
                        : () => _selectDog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      minimumSize: const Size(250, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      walkState.isWalking ? 'Go to your walk' : 'Start Walk',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => _showAchievementDetails(
                  context,
                  ref.read(activeWalkPetsProvider).first.id,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  height: 150,
                  child: const AchievementSection(),
                ),
              ),
              const SizedBox(height: 10),
              CompetitionFriendsLeaderboard(
                isExpanded: true,
                onExpandToggle: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
