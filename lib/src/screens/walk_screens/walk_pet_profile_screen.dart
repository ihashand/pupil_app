import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_achievement_card.dart';

class PetProfileScreen extends StatelessWidget {
  final Pet pet;

  const PetProfileScreen({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatPetName(pet.name),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3, // Odstępy między literami
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Nieruchomy nagłówek
          _buildHeaderSection(context),
          // Przewijana reszta
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Dodajemy tutaj sekcję osiągnięć
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
                    title: 'Achievements',
                    content: _buildPetAchievements(context),
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
    return name.toUpperCase().split('').join(' '); // Formatowanie każdej litery
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
            backgroundImage: AssetImage(pet.avatarImage),
            radius: 70, // Zwiększony rozmiar awatara
          ),
          const SizedBox(height: 20),
          _buildPetDetailsRow(context),
        ],
      ),
    );
  }

  Widget _buildPetDetailsRow(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceAround, // Równe rozmieszczenie danych
      children: [
        _buildDetailItem(
          context,
          emoji: '🐶',
          label: 'Breed',
          value: pet.breed,
        ),
        GestureDetector(
          onTap: () {
            _showBirthdayToast(pet.age);
          },
          child: _buildDetailItem(
            context,
            emoji: '🎂',
            label: 'Age',
            value: _calculateAge(pet.age), // Obliczanie wieku
          ),
        ),
        _buildDetailItem(
          context,
          emoji: pet.gender == 'Male' ? '♂️' : '♀️',
          label: 'Gender',
          value: pet.gender,
        ),
      ],
    );
  }

  // Funkcja obliczająca wiek na podstawie daty urodzenia
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
          style: const TextStyle(fontSize: 28), // Większa emotikonka
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: _infoTextStyle(context, isLarge: false),
        ),
      ],
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
      height: 150, // Stała wysokość dla wszystkich kontenerów z danymi
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

  // Sekcja osiągnięć
  Widget _buildAchievementsSection(BuildContext context) {
    return FutureBuilder<List<Achievement>>(
      future: _fetchAchievements(pet.achievementIds ?? []),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error fetching achievements');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildAchievementsGrid(context, snapshot.data!);
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

  Widget _buildAchievementsGrid(
      BuildContext context, List<Achievement> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Brak przewijania
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return FriendsAchievementCard(
          context: context,
          achievement: achievement,
          petsWithAchievement: [pet], // Przypisujemy osiągnięcie do psa
          isAchieved: true,
        );
      },
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

  Widget _buildPetAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievement 1: First Walk', style: _infoTextStyle(context)),
        Text('Achievement 2: 1000 Steps', style: _infoTextStyle(context)),
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
      fontSize: isLarge ? 16 : 14, // Zmniejszona czcionka dla danych o psie
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
