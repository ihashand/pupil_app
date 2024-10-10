import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/friends_screens/friend_statistic_screen.dart';
import 'package:pet_diary/src/components/achievement_widgets/achievement_card.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const PetProfileScreen({required this.pet, super.key});

  @override
  createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
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

  Widget _buildAchievementsSection(BuildContext context) {
    return FutureBuilder<List<Achievement>>(
      future: _fetchAchievements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error fetching achievements');
        } else if (snapshot.hasData) {
          List<Achievement> allAchievements = snapshot.data!;
          List<Achievement> earnedAchievements = allAchievements
              .where((achievement) =>
                  widget.pet.achievementIds?.contains(achievement.id) ?? false)
              .toList();

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
                          _showAllAchievementsMenu(context, allAchievements);
                        },
                        child: Text(
                          'S e e  a l l',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 15,
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
                  children: earnedAchievements.take(6).map((achievement) {
                    return AchievementCard(
                      context: context,
                      achievement: achievement,
                      petsWithAchievement: [widget.pet],
                      isAchieved: true,
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
              // Filtrowanie osiągnięć na podstawie wybranej kategorii
              List<Achievement> filteredAchievements =
                  achievements.where((achievement) {
                return selectedCategory == 'all' ||
                    achievement.category == selectedCategory;
              }).toList();

              // Podział osiągnięć na zdobyte i niezdobyte
              List<Achievement> earnedAchievements = filteredAchievements
                  .where((achievement) =>
                      widget.pet.achievementIds?.contains(achievement.id) ??
                      false)
                  .toList();

              List<Achievement> unearnedAchievements = filteredAchievements
                  .where((achievement) =>
                      !(widget.pet.achievementIds?.contains(achievement.id) ??
                          false))
                  .toList();

              int totalAchievements = filteredAchievements.length;
              int earnedAchievementsCount = earnedAchievements.length;

              double percentage = totalAchievements == 0
                  ? 0
                  : (earnedAchievementsCount / totalAchievements) * 100;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 18.0, left: 20, bottom: 2),
                        child: Text(
                          'A C H I E V E M E N T S',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark),
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
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                    thickness: 1.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    '🎯',
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$earnedAchievementsCount / $totalAchievements',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total achievements earned',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    _getAchievementEmoticon(percentage),
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildMotivationalTextWidget(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: earnedAchievements.length +
                          unearnedAchievements.length,
                      itemBuilder: (context, index) {
                        Achievement achievement;
                        bool hasAchieved;

                        if (index < earnedAchievements.length) {
                          achievement = earnedAchievements[index];
                          hasAchieved = true;
                        } else {
                          achievement = unearnedAchievements[
                              index - earnedAchievements.length];
                          hasAchieved = false;
                        }

                        return AchievementCard(
                          context: context,
                          achievement: achievement,
                          petsWithAchievement: [widget.pet],
                          isAchieved: hasAchieved,
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

  String _getAchievementEmoticon(double percentage) {
    if (percentage < 10) return '💪';
    if (percentage < 20) return '🔥';
    if (percentage < 30) return '🏆';
    if (percentage < 40) return '🚀';
    if (percentage < 50) return '💯';
    if (percentage < 60) return '🎉';
    if (percentage < 70) return '🌟';
    if (percentage < 80) return '🏅';
    if (percentage < 90) return '⭐';
    return '👑';
  }

  Widget _buildMotivationalTextWidget() {
    final motivationalTexts = [
      'Great start, keep it up!',
      'Amazing effort, don’t stop now!',
      'Incredible progress, well done!',
      'One step at a time, keep going!',
      'No limits, just possibilities!',
    ];

    final randomText =
        motivationalTexts[Random().nextInt(motivationalTexts.length)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        randomText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  // Funkcja pobierająca wszystkie osiągnięcia z bazy danych
  Future<List<Achievement>> _fetchAchievements() async {
    final List<Achievement> achievements = [];
    final snapshot =
        await FirebaseFirestore.instance.collection('achievements').get();
    for (var doc in snapshot.docs) {
      achievements.add(Achievement.fromDocument(doc));
    }
    return achievements;
  }

  // Metoda do wyświetlania przycisków kategorii
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
              ? Theme.of(context).colorScheme.inversePrimary
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

  // Formatuje imię zwierzaka do wyświetlania w AppBarze
  String _formatPetName(String name) {
    return name.toUpperCase().split('').join(' ');
  }

  // Sekcja nagłówka z awatarem i danymi zwierzaka
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

  // Szczegóły zwierzaka w nagłówku
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

  // Oblicza wiek zwierzaka na podstawie daty urodzenia
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

  // Wyświetla toast z datą urodzenia
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

  // Wyświetla szczegóły zwierzaka w nagłówku
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

  // Sekcja przycisków akcji
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

  // Styl tekstu dla informacji
  TextStyle _infoTextStyle(BuildContext context, {bool isLarge = false}) {
    return TextStyle(
      fontSize: isLarge ? 16 : 14,
      color: Theme.of(context).primaryColorDark,
    );
  }
}
