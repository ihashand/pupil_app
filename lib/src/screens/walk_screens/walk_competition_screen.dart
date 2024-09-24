import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/competition/achievement_details_dialog.dart';
import 'package:pet_diary/src/components/competition/achievement_section.dart';
import 'package:pet_diary/src/components/competition/competition_friends_leaderboard.dart';
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
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final asyncPets = ref.watch(petsProvider);

            return asyncPets.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Error fetching pets'),
              data: (pets) {
                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return ListTile(
                      title: Text(pet.name),
                      onTap: () {
                        Navigator.pop(context, pet);
                      },
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

  void _showAchievementDetails(BuildContext context, String achievementName,
      int currentSteps, int totalSteps, String assetPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: AchievementDetailsDialog(
            achievementName: achievementName,
            currentSteps: currentSteps,
            totalSteps: totalSteps,
            assetPath: assetPath,
          ),
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
                  "Achievement Name",
                  45000,
                  50000,
                  'assets/achievement.png',
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  height: 250,
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
