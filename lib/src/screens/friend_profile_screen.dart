import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/app_user_model.dart';
import 'package:pet_diary/src/models/friend_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/friend_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/user_achievement_provider.dart';
import 'package:pet_diary/src/screens/friend_pet_detail_screen.dart';
import 'package:pet_diary/src/screens/friend_statistic_screen.dart';
import 'package:pet_diary/src/screens/friends_screen.dart';
import 'package:pet_diary/src/screens/pet_details_screen.dart';
import 'package:pet_diary/src/widgets/achievement_widgets/initialize_achievements.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/section_title.dart';
import 'package:pet_diary/src/widgets/report_widget/show_date_range_dialog.dart';
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
        ConfettiController(duration: const Duration(seconds: 3));
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
              _buildPetsList(context, user),
              const SizedBox(height: 20),
              if (user.id == currentUserId) ...[
                const SectionTitle(title: "Generate Report"),
                GenerateReportSection(petId: user.id),
              ],
              _buildAchievementsSection(context, user.id),
              const SizedBox(height: 20),
              _buildActionButtons(context, asyncWalks),
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
                  ],
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

  Widget _buildPetsList(BuildContext context, AppUserModel user) {
    final asyncPets = ref.watch(petFriendServiceProvider(user.id));
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: asyncPets.when(
        data: (pets) {
          final userPets = pets.where((pet) => pet.userId == user.id).toList();
          if (userPets.isEmpty) {
            return const Text('No pets found.');
          }
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: userPets.asMap().entries.map((entry) {
                int index = entry.key;
                Pet pet = entry.value;
                return Column(
                  children: [
                    _buildPetTile(context, pet, currentUserId == user.id),
                    if (index < userPets.length - 1)
                      Divider(color: Theme.of(context).colorScheme.surface),
                  ],
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  Widget _buildPetTile(BuildContext context, Pet pet, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(pet.avatarImage),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            pet.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            calculateAge(pet.age),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        trailing: TextButton(
          onPressed: () {
            if (isCurrentUser) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailsScreen(petId: pet.id),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendPetDetailScreen(petId: pet.id),
                ),
              );
            }
          },
          child: const Text('See'),
        ),
      ),
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
        padding: const EdgeInsets.all(8.0),
        width: 120,
        height: 180,
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(achievement.avatarUrl),
              radius: 40,
            ),
            const SizedBox(height: 10),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton(context, setState, 'all'),
                    _buildCategoryButton(context, setState, 'steps'),
                    _buildCategoryButton(context, setState, 'nature'),
                    _buildCategoryButton(context, setState, 'fantasy'),
                  ],
                ),
                Expanded(
                  child: FutureBuilder<Set<String>>(
                    future: _getUserAchievementIds(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No achievements found.'),
                        );
                      } else {
                        final achievedIds = snapshot.data!;
                        return ListView(
                          children: [
                            _buildAchievementsCategory(
                                context, userId, selectedCategory, achievedIds),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, StateSetter setState, String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColorDark,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
    );
  }

  Widget _buildAchievementsCategory(BuildContext context, String userId,
      String category, Set<String> achievedIds) {
    final categoryAchievements = achievements
        .where((achievement) =>
            category == 'all' || achievement.category == category)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
          ),
          itemCount: categoryAchievements.length,
          itemBuilder: (context, index) {
            final achievement = categoryAchievements[index];
            final hasAchieved = achievedIds.contains(achievement.id);
            return GestureDetector(
              onTap: hasAchieved
                  ? () =>
                      _showAchievementDetail(context, achievement, hasAchieved)
                  : null,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: hasAchieved
                      ? null
                      : BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        child: hasAchieved
                            ? null
                            : const Icon(Icons.lock, color: Colors.white),
                        backgroundImage: hasAchieved
                            ? AssetImage(achievement.avatarUrl)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hasAchieved ? achievement.name : '???',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasAchieved ? Colors.black : Colors.grey),
                      ),
                      if (!hasAchieved)
                        Text(
                          achievement.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
                  CircleAvatar(
                    backgroundImage: AssetImage(achievement.avatarUrl),
                    radius: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    achievement.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    achievement.description,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add share functionality here
                    },
                    child: const Text('Share'),
                  ),
                ],
              ),
            ),
            if (hasAchieved)
              ConfettiWidget(
                confettiController: _confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
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
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.bar_chart,
                  color: Theme.of(context).primaryColorDark),
              title: Text('Statistics',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
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
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
              onTap: () {
                // Navigate to activity screen
              },
            ),
            Divider(
              color: Theme.of(context).colorScheme.surface,
            ),
            ListTile(
              leading:
                  Icon(Icons.map, color: Theme.of(context).primaryColorDark),
              title: Text('Routes',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
              onTap: () {
                // Navigate to routes screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GenerateReportSection extends ConsumerWidget {
  final String petId;

  const GenerateReportSection({
    required this.petId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xff68a2b6)),
          const SizedBox(height: 8),
          Text(
            "Generate a detailed health report in PDF, chose the date range and generate it for free!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
          const Divider(color: Colors.grey, height: 20),
          TextButton(
            onPressed: () async {
              final pet = await ref.read(petServiceProvider).getPetById(petId);
              if (pet != null) {
                // ignore: use_build_context_synchronously
                await showDateRangeDialog(context, ref, pet);
              }
            },
            child: Text(
              "Generate Report",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
