import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_diary/src/helpers/others/calculate_age.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/models/others/app_user_model.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/others_providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/friend_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_achievement_provider.dart';
import 'package:pet_diary/src/screens/friends_screens/friend_statistic_screen.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_achievement_card.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_screen.dart';
import 'package:pet_diary/src/components/achievement_widgets/initialize_achievements.dart';
import 'package:pet_diary/src/components/report_widget/generate_report_card.dart';
import 'package:pet_diary/src/components/health_activity_widgets/section_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:share/share.dart';
import 'package:screenshot/screenshot.dart';

class FriendProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const FriendProfileScreen({required this.userId, super.key});

  @override
  createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  int touchedIndex = -1;
  int selectedMonthIndex = DateTime.now().month - 1;
  final int maxMonths = 12;
  late List<BarChartGroupData> barGroups;
  String selectedCategory = 'all';
  ConfettiController? _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    barGroups = showingGroups();
    selectedMonthIndex = DateTime.now().month - 1;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(maxMonths, (i) {
      return makeGroupData(i, Random().nextInt(15).toDouble() + 6);
    });
  }

  List<BarChartGroupData> showingGroupsWithRealData(
      Map<int, double> monthlyStatistics) {
    return List.generate(maxMonths, (i) {
      return makeGroupData(i, monthlyStatistics[i] ?? 0);
    });
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: x == selectedMonthIndex
              ? Colors.red
              : x == DateTime.now().month - 1
                  ? const Color(0xff68a2b6)
                  : const Color(0xffdfd785),
          width: 20,
          borderSide: touchedIndex == x
              ? BorderSide(color: Colors.red.darken(1))
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
      showingTooltipIndicators: touchedIndex == x ? [0] : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(appUserDetailsProvider(widget.userId));
    final friendsAsyncValue = ref.watch(friendsStreamProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'F R I E N D  P R O F I L E',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: userAsyncValue.when(
          data: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoAndFriends(context, user, friendsAsyncValue),
              _buildAchievementsSection(context, user.id),
              _buildActionButtons(context),
              if (user.id == currentUserId) ...[
                const SectionTitle(title: "Generate Report"),
                GenerateReportCard(petId: user.id),
              ],
              const SizedBox(
                height: 50,
              )
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildUserInfoAndFriends(BuildContext context, AppUserModel user,
      AsyncValue<List<Friend>> friendsAsyncValue) {
    final asyncPets = ref.watch(petFriendServiceProvider(user.id));
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username[0].toUpperCase() +
                          user.username.substring(1),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 5),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(user.avatarUrl),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: friendsAsyncValue.when(
              data: (friends) {
                final friendCount = friends.length;
                return asyncPets.when(
                  data: (pets) {
                    final petCount =
                        pets.where((pet) => pet.userId == user.id).length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FriendsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Friends: $friendCount',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: TextButton(
                            onPressed: () {
                              _showPetsList(context, user.id);
                            },
                            child: Text(
                              'Pets: $petCount',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
        ],
      ),
    );
  }

  void _showPetsList(BuildContext context, String userId) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      builder: (BuildContext context) {
        final asyncPets = ref.watch(petFriendServiceProvider(userId));
        return asyncPets.when(
          data: (pets) {
            final userPets = pets.where((pet) => pet.userId == userId).toList();
            if (userPets.isEmpty) {
              return const Center(child: Text('No pets found.'));
            }
            double heightFactor = userPets.length * 0.1;
            heightFactor = heightFactor > 1.0 ? 1.0 : heightFactor;

            return FractionallySizedBox(
              heightFactor: heightFactor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: userPets.length,
                  itemBuilder: (context, index) {
                    final pet = userPets[index];
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(pet.avatarImage),
                          radius: 35,
                        ),
                        title: Text(pet.name),
                        subtitle: Text('Age: ${calculateAge(pet.age)}'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }

  Future<Achievement> _getAchievementById(String achievementId) async {
    return achievements.firstWhere(
      (achievement) => achievement.id == achievementId,
    );
  }

  void _showAchievementsMenu(
      BuildContext context, String userId, List<Pet> pets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 18.0, left: 16, bottom: 2),
                        child: Text(
                          'Achievements',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0, right: 16),
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          radius: 15,
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 22,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        _buildCategoryButton(context, setState, 'all'),
                        _buildCategoryButton(context, setState, 'steps'),
                        _buildCategoryButton(context, setState, 'nature'),
                        _buildCategoryButton(context, setState, 'seasonal'),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: FutureBuilder<Set<String>>(
                      future: _getUserAchievementIdsForAllPets(userId, pets),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No achievements found.'),
                          );
                        } else {
                          final achievedIds = snapshot.data!;
                          return ListView(
                            children: [
                              _buildAchievementsCategory(context, userId,
                                  selectedCategory, achievedIds, pets),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<Set<String>> _getUserAchievementIdsForAllPets(
      String userId, List<Pet> pets) async {
    Set<String> allAchievementIds = {};

    for (var pet in pets) {
      final petAchievementsSnapshot = await FirebaseFirestore.instance
          .collection('app_users')
          .doc(userId)
          .collection('pets')
          .doc(pet.id)
          .collection('pet_achievements')
          .where('userId', isEqualTo: userId)
          .get();

      final petAchievementIds = petAchievementsSnapshot.docs
          .map((doc) => doc.get('achievementId') as String)
          .toSet();

      allAchievementIds.addAll(petAchievementIds);
    }

    return allAchievementIds;
  }

  Widget _buildCategoryButton(
      BuildContext context, StateSetter setState, String category) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColorDark,
          backgroundColor: isSelected
              ? const Color(0xff68a2b6)
              : Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          category.toUpperCase(),
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAchievementsCategory(BuildContext context, String userId,
      String category, Set<String> achievedIds, List<Pet> pets) {
    final categoryAchievements = achievements.where((achievement) {
      return category == 'all' || achievement.category == category;
    }).toList();

    categoryAchievements.sort((a, b) {
      final aAchieved = achievedIds.contains(a.id);
      final bAchieved = achievedIds.contains(b.id);
      if (aAchieved && !bAchieved) return -1;
      if (!aAchieved && bAchieved) return 1;
      return 0;
    });

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 10),
            child: Text(
              category.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
            ),
            itemCount: categoryAchievements.length,
            itemBuilder: (context, index) {
              final achievement = categoryAchievements[index];
              final hasAchieved = achievedIds.contains(achievement.id);

              final petsWithAchievement = pets.where((pet) {
                return pet.achievementIds!.contains(achievement.id);
              }).toList();

              return FriendsAchievementCard(
                context: context,
                achievement: achievement,
                petsWithAchievement: petsWithAchievement,
                isAchieved: hasAchieved,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAchievementDetail(
      BuildContext context, Achievement achievement, bool hasAchieved) {
    if (hasAchieved) {
      _confettiController?.play();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        radius: 15,
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 22,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Screenshot(
                    controller: _screenshotController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(achievement.avatarUrl),
                            radius: 100,
                          ),
                        ),
                        Text(
                          achievement.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          achievement.description,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // Przycisk udostępniania przeniesiony poza obszar Screenshot
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 40),
                      foregroundColor: Theme.of(context).primaryColorDark,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      final Uint8List? imageBytes =
                          await _screenshotController.capture();
                      if (imageBytes != null) {
                        final tempDir = await getTemporaryDirectory();
                        final file =
                            await File('${tempDir.path}/achievement.png')
                                .create();
                        await file.writeAsBytes(imageBytes);

                        Share.shareFiles([file.path],
                            text:
                                'I unlocked the achievement ${achievement.name}!\n\n${achievement.description}');
                      }
                    },
                    child: Text(
                      'Share',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ],
              ),
            ),
            if (hasAchieved)
              ConfettiWidget(
                confettiController: _confettiController!,
                blastDirectionality: BlastDirectionality.directional,
                shouldLoop: false,
                blastDirection: -pi / 2,
                maxBlastForce: 30,
                minBlastForce: 15,
                gravity: 0.03,
                colors: const [
                  Color(0xffdfd785),
                  Color(0xff68a2b6),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.bar_chart,
                  color: Theme.of(context).primaryColorDark),
              title: Text('Statistics',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14)),
              onTap: () {
                final userAsyncValue =
                    ref.read(appUserDetailsProvider(widget.userId));
                userAsyncValue.whenData((user) {
                  final asyncPets = ref.read(petFriendServiceProvider(user.id));
                  asyncPets.whenData((pets) {
                    if (pets.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsScreen(
                            initialPet: pets.first,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    }
                  });
                });
              },
            ),
            Divider(
              color: Theme.of(context).colorScheme.surface,
            ),
            ListTile(
              leading: Icon(Icons.directions_walk,
                  color: Theme.of(context).primaryColorDark),
              title: Text('Activity',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14)),
              onTap: () {},
            ),
            Divider(
              color: Theme.of(context).colorScheme.surface,
            ),
            ListTile(
              leading:
                  Icon(Icons.map, color: Theme.of(context).primaryColorDark),
              title: Text('Routes',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, String userId) {
    final asyncPets = ref.watch(petFriendServiceProvider(userId));

    return asyncPets.when(
      data: (pets) {
        if (pets.isEmpty) {
          return const Center(child: Text('No pets found.'));
        }

        // Lista do przechowywania wszystkich zdobytych achievementów
        Map<String, List<Pet>> uniqueAchievements = {};

        // Pobierz zdobyte achievementy dla każdego zwierzaka
        final futures = pets.map((pet) async {
          final petAchievements =
              await ref.read(petAchievementsProvider(pet.id).future);
          for (var achievement in petAchievements) {
            if (!uniqueAchievements.containsKey(achievement.achievementId)) {
              uniqueAchievements[achievement.achievementId] = [];
            }
            uniqueAchievements[achievement.achievementId]!.add(pet);
          }
        });

        return FutureBuilder<void>(
          future: Future.wait(futures),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading achievements.'));
            }

            // Wyświetlamy zdobyte achievementy nad przyciskami
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionTitle(title: "Achievements"),
                    TextButton(
                      onPressed: () {
                        _showAchievementsMenu(context, userId, pets);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: uniqueAchievements.entries.map((entry) {
                      final achievementId = entry.key;
                      final petsWithAchievement = entry.value;

                      return FutureBuilder<Achievement>(
                        future: _getAchievementById(achievementId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error loading achievement.');
                          } else if (!snapshot.hasData) {
                            return const Text('Achievement not found.');
                          }

                          final achievementData = snapshot.data!;
                          return GestureDetector(
                            onTap: () => _showAchievementDetail(
                                context, achievementData, true),
                            child: FriendsAchievementCard(
                              context: context,
                              achievement: achievementData,
                              petsWithAchievement: petsWithAchievement,
                              isAchieved: true,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Error loading pets.')),
    );
  }
}
