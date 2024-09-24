import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_diary/src/components/health_activity_widgets/section_title.dart';
import 'package:pet_diary/src/helpers/extensions/string_extension.dart';
import 'package:pet_diary/src/helpers/others/calculate_age.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/providers/achievements_providers/achievements_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const PetProfileScreen({required this.pet, Key? key}) : super(key: key);

  @override
  createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
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
    final achievementsAsyncValue = ref.watch(achievementServiceProvider);
    final asyncWalks = ref.watch(eventWalksProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          '${widget.pet.name.toUpperCase()}\'S PROFILE',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPetInfoSection(context),
            _buildAchievementsSection(context, achievementsAsyncValue),
            _buildActionButtons(context, asyncWalks),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoSection(BuildContext context) {
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
                      widget.pet.name.capitalizeWord(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Breed: ${widget.pet.breed}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark),
                    ),
                    Text(
                      'Age: ${calculateAge(widget.pet.age)} years',
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
                  backgroundImage: AssetImage(widget.pet.avatarImage),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(
      BuildContext context, AsyncValue<List<String>> achievementsAsyncValue) {
    return achievementsAsyncValue.when(
      data: (achievements) {
        if (achievements.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                _showAchievementsMenu(context);
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
                    _showAchievementsMenu(context);
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
                children: achievements.map((achievement) {
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
                            backgroundImage:
                                AssetImage('assets/images/achievement.png'),
                            radius: 45,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            achievement,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  void _showAchievementsMenu(BuildContext context) {
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
                  Expanded(
                    child:
                        Center(child: Text('Achievements list will be here.')),
                  ),
                ],
              );
            },
          ),
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
                // Tutaj możemy dodać szczegóły statystyk psa
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
                // Tutaj możemy dodać szczegóły aktywności psa
              },
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
              onTap: () {
                // Tutaj możemy dodać trasy psa
              },
            ),
          ],
        ),
      ),
    );
  }
}
