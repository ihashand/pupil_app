import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_achievement_card.dart';

class PetProfileScreen extends StatefulWidget {
  final Pet pet;

  const PetProfileScreen({required this.pet, super.key});

  @override
  createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  String selectedCategory = 'all';
  bool showCategories = false;

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
      body: Column(
        children: [
          _buildHeaderSection(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (showCategories) _buildAchievementsCategoryFilter(context),
                  const SizedBox(height: 10),
                  // _buildDetailsButton(context), //todo: musze cos pomyslec jak to przerobic, ale brak weny dzisiaj :(
                  _buildAchievementsSection(context),
                  const SizedBox(height: 20),
                  _buildDataSection(
                    context,
                    title: 'Statistics',
                    content: _buildPetStatistics(context),
                  ),
                  const SizedBox(height: 20),
                  _buildDataSection(
                    context,
                    title: 'Routes',
                    content: _buildPetRoutes(context),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Divider(color: Theme.of(context).colorScheme.surface),
          const SizedBox(height: 10),
          CircleAvatar(
            backgroundImage: AssetImage(widget.pet.avatarImage),
            radius: 70,
          ),
          const SizedBox(height: 20),
          _buildPetDetailsRow(context),
        ],
      ),
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showCategories = !showCategories;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        showCategories ? 'Hide Details' : 'Show Details',
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPetDetailsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDetailItem(
          context,
          emoji: '🐶',
          label: 'Breed',
          value: widget.pet.breed,
        ),
        GestureDetector(
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
        _buildDetailItem(
          context,
          emoji: widget.pet.gender == 'Male' ? '♂️' : '♀️',
          label: 'Gender',
          value: widget.pet.gender,
        ),
      ],
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

  Widget _buildAchievementsCategoryFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryButton(context, 'all'),
        const SizedBox(width: 10),
        _buildCategoryButton(context, 'steps'),
        const SizedBox(width: 10),
        _buildCategoryButton(context, 'nature'),
        const SizedBox(width: 10),
        _buildCategoryButton(context, 'seasonal'),
      ],
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category) {
    bool isSelected = selectedCategory == category;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
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
          color: Theme.of(context).primaryColorDark,
          fontSize: 12,
        ),
      ),
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
          final filteredAchievements = snapshot.data!
              .where((achievement) =>
                  selectedCategory == 'all' ||
                  achievement.category == selectedCategory)
              .toList();

          return _buildAchievementsRow(context, filteredAchievements);
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

  Widget _buildAchievementsRow(
      BuildContext context, List<Achievement> achievements) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: FriendsAchievementCard(
              context: context,
              achievement: achievement,
              petsWithAchievement: [widget.pet],
              isAchieved: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: _sectionTitleStyle(context),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildPetStatistics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps: 5000', style: _infoTextStyle(context)),
        Text('Distance: 10 km', style: _infoTextStyle(context)),
      ],
    );
  }

  Widget _buildPetRoutes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No routes available yet.', style: _infoTextStyle(context)),
      ],
    );
  }

  TextStyle _infoTextStyle(BuildContext context, {bool isLarge = false}) {
    return TextStyle(
      fontSize: isLarge ? 16 : 14,
      color: Theme.of(context).primaryColorDark,
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColorDark,
    );
  }
}
