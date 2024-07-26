import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/app_user_model.dart';
import 'package:pet_diary/src/models/friend_model.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/friend_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/user_achievement_provider.dart';
import 'package:pet_diary/src/screens/friend_statistic_screen.dart';
import 'package:pet_diary/src/screens/friends_screen.dart';
import 'package:pet_diary/src/widgets/achievement_widgets/initialize_achievements.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/generate_report_section.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/section_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import '../models/achievement.dart';

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
    final asyncWalks = ref.watch(eventWalksProvider);
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
              _buildActionButtons(context, asyncWalks),
              _buildAchievementsSection(context, user.id),
              if (user.id == currentUserId) ...[
                const SectionTitle(title: "Generate Report"),
                GenerateReportSection(petId: user.id),
              ],
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

  Widget _buildAchievementsSection(BuildContext context, String userId) {
    final asyncAchievements = ref.watch(userAchievementsProvider);

    return asyncAchievements.when(
      data: (userAchievements) {
        if (userAchievements.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                _showAchievementsMenu(context, userId);
              },
              child: Text(
                'View Achievements',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          );
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionTitle(title: "Achievements"),
                TextButton(
                  onPressed: () {
                    _showAchievementsMenu(context, userId);
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
                children: userAchievements.map((userAchievement) {
                  return FutureBuilder<Achievement>(
                    future: _getAchievementById(userAchievement.achievementId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('Achievement not found');
                      }

                      final achievementData = snapshot.data!;
                      return GestureDetector(
                        onTap: () => _showAchievementDetail(
                            context, achievementData, true),
                        child: _buildAchievementCard(achievementData),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Future<Achievement> _getAchievementById(String achievementId) async {
    return achievements.firstWhere(
      (achievement) => achievement.id == achievementId,
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        width: 120,
        height: 180,
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(achievement.avatarUrl),
              radius: 45,
            ),
            const SizedBox(height: 10),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementsMenu(BuildContext context, String userId) {
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
                                size: 22, // Ustawienie rozmiaru ikony
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
                        _buildCategoryButton(context, setState, 'fantasy'),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: FutureBuilder<Set<String>>(
                      future: _getUserAchievementIds(userId),
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
                                  selectedCategory, achievedIds),
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
      String category, Set<String> achievedIds) {
    final categoryAchievements = achievements
        .where((achievement) =>
            category == 'all' || achievement.category == category)
        .toList();

    if (category == 'all') {
      categoryAchievements.sort((a, b) {
        final aAchieved = achievedIds.contains(a.id);
        final bAchieved = achievedIds.contains(b.id);
        if (aAchieved && !bAchieved) return -1;
        if (!aAchieved && bAchieved) return 1;
        return 0; // Here we can replace with a custom sort if needed
      });
    }

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
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
            ),
            itemCount: categoryAchievements.length,
            itemBuilder: (context, index) {
              final achievement = categoryAchievements[index];
              final hasAchieved = achievedIds.contains(achievement.id);
              return GestureDetector(
                onTap: hasAchieved
                    ? () => _showAchievementDetail(
                        context, achievement, hasAchieved)
                    : null,
                child: Card(
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(.0),
                    decoration: hasAchieved
                        ? null
                        : BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: hasAchieved
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          backgroundImage: hasAchieved
                              ? AssetImage(
                                  achievement.avatarUrl,
                                )
                              : null,
                          child: hasAchieved
                              ? null
                              : Icon(
                                  Icons.lock,
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.5),
                                  size: 60,
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hasAchieved ? achievement.name : '???',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: hasAchieved ? Colors.black : Colors.grey),
                        ),
                        Text(
                          achievement.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Set<String>> _getUserAchievementIds(String userId) async {
    final userAchievementsSnapshot = await FirebaseFirestore.instance
        .collection('app_users')
        .doc(userId)
        .collection('user_achievements')
        .where('userId', isEqualTo: userId)
        .get();

    return userAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();
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
                              size: 22, // Ustawienie rozmiaru ikony
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 40),
                      foregroundColor: Theme.of(context).primaryColorDark,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      // Add share functionality here
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

  Widget _buildActionButtons(
      BuildContext context, AsyncValue<List<EventWalkModel?>> asyncWalks) {
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
}
