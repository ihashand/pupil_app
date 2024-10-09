import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/friends_screens/friend_statistic_screen.dart';
import 'package:pet_diary/src/components/achievement_widgets/achievement_card.dart';

class WalkPetProfileScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const WalkPetProfileScreen({required this.pet, super.key});

  @override
  createState() => _WalkPetProfileScreenState();
}

class _WalkPetProfileScreenState extends ConsumerState<WalkPetProfileScreen> {
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatPetName(widget.pet.name),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context),
            _buildAchievementsSection(context),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15, 10, 35),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      initialPet: widget.pet,
                      userId: widget.pet.userId,
                      isSinglePetMode: true,
                    ),
                  ),
                );
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

  String _formatPetName(String name) {
    return name.toUpperCase().split('').join(' ');
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Divider(
            thickness: 1.0,
            color: Theme.of(context).colorScheme.surface,
          ),
          CircleAvatar(
            backgroundImage: AssetImage(widget.pet.avatarImage),
            radius: 70,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: _buildPetDetailsRow(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildDetailItem(
                context,
                emoji: '🐶',
                label: 'Breed',
                value: widget.pet.breed,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  _showBirthdayToast(widget.pet.age);
                },
                child: _buildDetailItem(
                  context,
                  emoji: '🎂',
                  label: 'Age',
                  value: _calculateAge(widget.pet.age),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildDetailItem(
                context,
                emoji: widget.pet.gender == 'Male' ? '♂️' : '♀️',
                label: 'Gender',
                value: widget.pet.gender,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String birthday) {
    DateTime birthDate = DateFormat('dd/MM/yyyy').parse(birthday);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return '$age years';
  }

  void _showBirthdayToast(String birthday) {
    Fluttertoast.showToast(
      msg: 'Born on: $birthday',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required String emoji, required String label, required String value}) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: _infoTextStyle(context, isLarge: false),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return FutureBuilder<List<Achievement>>(
      future: _fetchAchievements(widget.pet.achievementIds ?? []),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error fetching achievements');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<Achievement> achievements = snapshot.data!;
          achievements.shuffle();
          final displayAchievements = achievements.take(6).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        "A c h i e v e m e n t s",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: TextButton(
                        onPressed: () {
                          _showAllAchievementsMenu(context, achievements);
                        },
                        child: Text(
                          'S e e  A l l',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: displayAchievements.map((achievement) {
                    Color randomColor = Colors.primaries[
                        (achievement.hashCode % Colors.primaries.length)];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: randomColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: AchievementCard(
                          context: context,
                          achievement: achievement,
                          petsWithAchievement: [widget.pet],
                          isAchieved: true,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        } else {
          return const Text('No achievements found');
        }
      },
    );
  }

  Future<List<Achievement>> _fetchAchievements(
      List<String> achievementIds) async {
    final List<Achievement> achievements = [];
    for (String achievementId in achievementIds) {
      final doc = await FirebaseFirestore.instance
          .collection('achievements')
          .doc(achievementId)
          .get();
      if (doc.exists) {
        achievements.add(Achievement.fromDocument(doc));
      }
    }
    return achievements;
  }

  void _showAllAchievementsMenu(
      BuildContext context, List<Achievement> achievements) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: StatefulBuilder(
            builder: (context, setState) {
              List<Achievement> filteredAchievements =
                  achievements.where((achievement) {
                return selectedCategory == 'all' ||
                    achievement.category == selectedCategory;
              }).toList();

              double itemHeight = 280;
              final double itemWidth =
                  MediaQuery.of(context).size.width / 2 - 20;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Achievements',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).primaryColorDark),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryButton(context, setState, 'all'),
                          _buildCategoryButton(context, setState, 'steps'),
                          _buildCategoryButton(context, setState, 'nature'),
                          _buildCategoryButton(context, setState, 'seasonal'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: itemWidth / itemHeight,
                      ),
                      itemCount: filteredAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = filteredAchievements[index];
                        return AchievementCard(
                          context: context,
                          achievement: achievement,
                          petsWithAchievement: [widget.pet],
                          isAchieved: true,
                        );
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColorDark,
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.secondary
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

  TextStyle _infoTextStyle(BuildContext context, {bool isLarge = false}) {
    return TextStyle(
      fontSize: isLarge ? 16 : 14,
      color: Theme.of(context).primaryColorDark,
    );
  }
}
