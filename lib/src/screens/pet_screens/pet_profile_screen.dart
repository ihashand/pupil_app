import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_weight_provider.dart';
import 'package:pet_diary/src/screens/events_screens/event_type_selection_screen.dart';
import 'package:pet_diary/src/screens/events_screens/events_screen.dart';
import 'package:pet_diary/src/screens/friends_screens/friend_statistic_screen.dart';
import 'package:pet_diary/src/components/achievement_widgets/achievement_card.dart';
import 'package:pet_diary/src/screens/activity_screens/activity_screen.dart';
import 'package:pet_diary/src/helpers/others/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/components/events/event_cards/event_health_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/screens/pet_screens/pet_edit_screen.dart';

// ignore: must_be_immutable
class PetProfileScreen extends ConsumerStatefulWidget {
  Pet pet;
  PetProfileScreen({required this.pet, super.key});

  @override
  createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  bool isOwner = false;
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _checkOwnership();
  }

  /// Sprawdza, czy obecny użytkownik jest właścicielem zwierzęcia
  Future<void> _checkOwnership() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final pets = await ref.read(petServiceProvider).getPetsByUserId(user.uid);

    setState(() {
      isOwner = pets.any((pet) => pet.id == widget.pet.id);
    });
  }

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
        actions: isOwner
            ? [
                IconButton(
                    icon: Icon(
                      Icons.settings,
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                    ),
                    onPressed: () async {
                      final updatedPet = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PetEditScreen(petId: widget.pet.id),
                        ),
                      );
                      if (updatedPet != null && updatedPet is Pet) {
                        setState(() {
                          widget.pet = updatedPet;
                        });
                      }
                    }),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSection(context),
                  const SizedBox(height: 10),
                  if (isOwner) _buildHealthEventSection(),
                  _buildAchievementsSection(context),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Buduje sekcję nagłówka z avatarem i detalami
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
          GestureDetector(
            onLongPress: isOwner
                ? () => showAvatarSelectionDialog(
                      context: context,
                      onAvatarSelected: (String path) {
                        setState(() {
                          widget.pet.avatarImage = path;
                        });
                        ref.read(petServiceProvider).updatePet(widget.pet);
                      },
                    )
                : null,
            child: CircleAvatar(
              backgroundImage: AssetImage(widget.pet.avatarImage),
              radius: 70,
            ),
          ),
          _buildPetDetailsRow(context),
        ],
      ),
    );
  }

  /// Buduje wiersz szczegółów zwierzęcia z ikonami i informacjami
  Widget _buildPetDetailsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showInfoDialog(context, 'Gender', widget.pet.gender,
                  widget.pet.gender == 'Male' ? '♂️' : '♀️'),
              child: _buildDetailItem(
                  context,
                  widget.pet.gender == 'Male' ? '♂️' : '♀️',
                  'Gender',
                  widget.pet.gender),
            ),
          ),
          if (isOwner)
            Expanded(
              child: GestureDetector(
                onTap: () => _showWeightInfoDialog(context),
                child: _buildPetWeight(context),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showInfoDialog(
                  context, 'Age', _calculateAge(widget.pet.age), '🎂'),
              child: _buildDetailItem(
                  context, '🎂', 'Age', _calculateAge(widget.pet.age)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  _showInfoDialog(context, 'Breed', widget.pet.breed, '🐶'),
              child: _buildDetailItem(
                  context, '🐶', 'Breed', _shortenBreed(widget.pet.breed)),
            ),
          ),
        ],
      ),
    );
  }

  /// Skraca nazwę rasy, jeśli jest zbyt długa
  String _shortenBreed(String breed) {
    return breed.length > 7 ? '${breed.substring(0, 5)}...' : breed;
  }

  /// Wyświetla animowany dialog na środku ekranu z informacją o wybranym szczególe
  Future<void> _showInfoDialog(
      BuildContext context, String label, String info, String emoji) async {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Pozwala na zamykanie przez kliknięcie poza dialogiem
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeInOut,
                  reverseCurve: Curves.easeInOut, // Animacja wygaszania
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(
                    left: 75, right: 75, top: 34, bottom: 35),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      info,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Buduje widżet szczegółu (ikona + tekst) do wyświetlania informacji
  Widget _buildDetailItem(
      BuildContext context, String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 5),
        Text(value,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).primaryColorDark)),
        const SizedBox(height: 5),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColorDark.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildPetWeight(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final asyncWeights = ref.watch(eventWeightsProvider);
        return asyncWeights.when(
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error fetching weight'),
          data: (weights) {
            var weight = weights
                .firstWhere(
                  (element) => element!.petId == widget.pet.id,
                  orElse: () => EventWeightModel(
                    id: '',
                    weight: 0.0,
                    eventId: '',
                    petId: widget.pet.id,
                    dateTime: DateTime.now(),
                  ),
                )!
                .weight;

            return GestureDetector(
              onTap: () => _showInfoDialog(
                context,
                'Weight',
                '$weight kg',
                '⚖️',
              ),
              child: _buildDetailItem(
                context,
                '⚖️',
                'Weight',
                '$weight kg',
              ),
            );
          },
        );
      },
    );
  }

  /// Buduje sekcję osiągnięć
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

          int remaining = 5 - earnedAchievements.length;
          List<Achievement> unearnedAchievements = allAchievements
              .where((achievement) =>
                  !(widget.pet.achievementIds?.contains(achievement.id) ??
                      false))
              .take(remaining)
              .toList();

          return Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildAchievementsHeader(context, allAchievements),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        ...earnedAchievements.map((achievement) => Opacity(
                              opacity: 0.8,
                              child: AchievementCard(
                                context: context,
                                achievement: achievement,
                                petsWithAchievement: [widget.pet],
                                isAchieved: true,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                petAvatarBackgroundColor:
                                    Theme.of(context).colorScheme.surface,
                              ),
                            )),
                        ...unearnedAchievements.map((achievement) => Opacity(
                              opacity: 0.4,
                              child: AchievementCard(
                                context: context,
                                achievement: achievement,
                                petsWithAchievement: [widget.pet],
                                isAchieved: false,
                                height: 240,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        } else {
          return const Text('No achievements found');
        }
      },
    );
  }

  /// Pobiera osiągnięcia z bazy danych
  Future<List<Achievement>> _fetchAchievements() async {
    final List<Achievement> achievements = [];
    final snapshot =
        await FirebaseFirestore.instance.collection('achievements').get();
    for (var doc in snapshot.docs) {
      achievements.add(Achievement.fromDocument(doc));
    }
    return achievements;
  }

  /// Buduje nagłówek sekcji osiągnięć
  Widget _buildAchievementsHeader(
      BuildContext context, List<Achievement> achievements) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            "Achievements",
            style: TextStyle(
                fontSize: 17,
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
              'See all',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pokazuje wszystkie osiągnięcia w menu
  void _showAllAchievementsMenu(
      BuildContext context, List<Achievement> allAchievements) {
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
                  _getFilteredAchievements(allAchievements, selectedCategory);

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
                  _buildAchievementModalHeader(context),
                  _buildCategoryFilterButtons(context, setState),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                    thickness: 1.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
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
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                    thickness: 1.0,
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
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

  /// Pobiera listę osiągnięć przefiltrowaną według kategorii
  List<Achievement> _getFilteredAchievements(
      List<Achievement> achievements, String category) {
    return category == 'all'
        ? achievements
        : achievements
            .where((achievement) => achievement.category == category)
            .toList();
  }

  /// Buduje nagłówek modalu osiągnięć
  Widget _buildAchievementModalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 20, bottom: 2),
          child: Text(
            'A C H I E V E M E N T S',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 16),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
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
    );
  }

  /// Buduje widżet z motywującym tekstem
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

  /// Buduje sekcję zdarzeń zdrowotnych
  Widget _buildHealthEventSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: EventHealthCard(
        onCreatePressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EventTypeSelectionScreen(petId: widget.pet.id),
          ),
        ),
      ),
    );
  }

  /// Buduje przyciski akcji
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
              leading:
                  Icon(Icons.event, color: Theme.of(context).primaryColorDark),
              title: Text('Events',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsScreen(widget.pet.id),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityScreen(
                      petId: widget.pet.id,
                    ),
                  ),
                );
              },
            ),
            Divider(
              color: Theme.of(context).colorScheme.surface,
            ),
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
          ],
        ),
      ),
    );
  }

  /// Formatuje imię zwierzęcia, aby było wyświetlane dużymi literami
  String _formatPetName(String name) {
    return name.toUpperCase().split('').join(' ');
  }

  /// Oblicza wiek zwierzęcia na podstawie daty urodzenia
  String _calculateAge(String birthdate) {
    final birthDate = DateFormat('dd/MM/yyyy').parse(birthdate);
    final currentDate = DateTime.now();

    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return '$age years';
  }

  /// Pobiera emotikonę osiągnięcia na podstawie procentu ukończenia
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

  void _showWeightInfoDialog(BuildContext context) {
    final asyncWeights = ref.read(eventWeightsProvider);
    asyncWeights.when(
      loading: () => showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Loading weight data...'),
        ),
      ),
      error: (err, stack) => showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Error fetching weight data'),
        ),
      ),
      data: (weights) {
        final weight = weights
            .firstWhere(
              (element) => element!.petId == widget.pet.id,
              orElse: () => EventWeightModel(
                id: '',
                weight: 0.0,
                eventId: '',
                petId: widget.pet.id,
                dateTime: DateTime.now(),
              ),
            )!
            .weight;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Weight'),
            content: Text('$weight kg'),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilterButtons(
      BuildContext context, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['all', 'steps', 'nature', 'seasonal']
              .map((category) => _buildCategoryButton(
                  context, setState, selectedCategory, category))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    StateSetter setState,
    String selectedCategory,
    String category,
  ) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            this.selectedCategory = category;
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
            color: Theme.of(context).primaryColorDark,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
