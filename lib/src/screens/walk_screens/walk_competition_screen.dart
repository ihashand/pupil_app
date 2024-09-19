import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/providers/others_providers/walk_state_provider.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_screen.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_in_progress_screen.dart';
import 'dart:async';
import 'dart:math';

enum Season { spring, summer, autumn, winter }

class WalkCompetitionScreen extends ConsumerStatefulWidget {
  const WalkCompetitionScreen({super.key});

  @override
  createState() => _WalkCompetitionScreenState();
}

class _WalkCompetitionScreenState extends ConsumerState<WalkCompetitionScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  String searchQuery = '';
  late AnimationController _animationController;
  List<int> selectedPetIndexes = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
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
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 20,
                              top: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Dog',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                TextButton(
                                  onPressed: selectedPetIndexes.isNotEmpty
                                      ? () {
                                          final selectedPets =
                                              selectedPetIndexes
                                                  .map((index) => pets[index])
                                                  .toList();
                                          ref
                                              .read(activeWalkPetsProvider
                                                  .notifier)
                                              .state = selectedPets;

                                          Navigator.pop(context);

                                          final walkNotifier =
                                              ref.read(walkProvider.notifier);
                                          walkNotifier.stopWalk();
                                          walkNotifier.startWalk();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WalkInProgressScreen(
                                                pets: selectedPets,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    'Start Walk',
                                    style: TextStyle(
                                      color: selectedPetIndexes.isNotEmpty
                                          ? Theme.of(context).primaryColorDark
                                          : Colors.grey.withOpacity(0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xff68a2b6)),
                          Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: pets.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          'No dogs available to display.',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Add a dog to start a walk.',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: pets
                                        .map(
                                          (pet) => GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                int index = pets.indexOf(pet);
                                                if (selectedPetIndexes
                                                    .contains(index)) {
                                                  selectedPetIndexes
                                                      .remove(index);
                                                } else {
                                                  selectedPetIndexes.add(index);
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedPetIndexes.contains(
                                                            pets.indexOf(pet))
                                                        ? Colors.grey
                                                            .withOpacity(0.2)
                                                        : Colors.transparent,
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: AssetImage(
                                                      pet.avatarImage),
                                                ),
                                                title: Text(pet.name),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
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
      body: Column(
        children: [
          // Przycisk start walk
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
                      color: Theme.of(context).primaryColorDark, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sekcja osiągnięć z sezonowym efektem
          Stack(
            children: [
              Center(
                  child:
                      AchievementSection()), // Wyśrodkowanie sekcji osiągnięć
              SeasonalEffect(
                season: Season.autumn, // Zmień na odpowiedni sezon
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Leaderboard
          Expanded(
            child: FriendsLeaderboard(isExpanded: true, onExpandToggle: () {}),
          ),
        ],
      ),
    );
  }
}

class AchievementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Achievement>(
      future: _getSeasonalAchievement(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No Achievement Data');
        }

        return AchievementWidget(
          achievementName: snapshot.data!.name,
          currentSteps: 45000,
          totalSteps: snapshot.data!.stepsRequired,
          assetPath: snapshot.data!.avatarUrl,
        );
      },
    );
  }

  Future<Achievement> _getSeasonalAchievement() async {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final seasonAchievementId =
        'seasonal_$currentYear _${currentMonth.toString().padLeft(2, '0')}';

    final seasonAchievement = await FirebaseFirestore.instance
        .collection('achievements')
        .doc(seasonAchievementId)
        .get();

    if (seasonAchievement.exists) {
      return Achievement.fromDocument(seasonAchievement);
    } else {
      return Future.error('No seasonal achievement found for this month.');
    }
  }
}

// SeasonalEffect class
class SeasonalEffect extends StatefulWidget {
  final Season season;

  const SeasonalEffect({super.key, required this.season});

  @override
  createState() => _SeasonalEffectState();
}

class _SeasonalEffectState extends State<SeasonalEffect> {
  final Random random = Random();
  List<SeasonalItem> seasonalItems = [];
  Timer? _seasonalTimer;
  final int maxItems = 20; // Maksymalna liczba ikon

  @override
  void initState() {
    super.initState();
    _startSeasonalAnimation();
  }

  void _startSeasonalAnimation() {
    _seasonalTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (seasonalItems.length >= maxItems) {
        _seasonalTimer?.cancel();
        return;
      }

      setState(() {
        seasonalItems.add(SeasonalItem(
          key: UniqueKey(),
          size: random.nextDouble() * 15 + 10,
          fallSpeed: random.nextDouble() * 2 + 1,
          xPosition: random.nextDouble(),
          season: widget.season,
        ));
      });
    });
  }

  @override
  void dispose() {
    _seasonalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Tylko w kontenerze z sekcją osiągnięć
      child: Stack(
        children: seasonalItems,
      ),
    );
  }
}

class SeasonalItem extends StatefulWidget {
  final double size;
  double fallSpeed;
  double xPosition;
  final Season season;

  SeasonalItem({
    Key? key,
    required this.size,
    required this.fallSpeed,
    required this.xPosition,
    required this.season,
  }) : super(key: key);

  @override
  _SeasonalItemState createState() => _SeasonalItemState();

  void reset() {
    final Random random = Random();
    xPosition = random.nextDouble();
    fallSpeed = random.nextDouble() * 2 + 1;
  }
}

class _SeasonalItemState extends State<SeasonalItem> {
  double yPosition = 0;
  Timer? _fallingTimer;

  @override
  void initState() {
    super.initState();
    _startFalling();
  }

  void _startFalling() {
    _fallingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        yPosition += widget.fallSpeed;
        if (yPosition > 200) {
          // Ograniczenie do kontenera
          yPosition = 0;
          widget.reset();
        }
      });
    });
  }

  @override
  void dispose() {
    _fallingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: widget.xPosition * MediaQuery.of(context).size.width,
      child: Opacity(
        opacity: 0.7,
        child: _getSeasonalIcon(),
      ),
    );
  }

  Widget _getSeasonalIcon() {
    switch (widget.season) {
      case Season.spring:
        return Icon(Icons.local_florist,
            size: widget.size, color: Colors.green);
      case Season.summer:
        return Icon(Icons.wb_sunny, size: widget.size, color: Colors.yellow);
      case Season.autumn:
        return Icon(Icons.park, size: widget.size, color: Colors.brown);
      case Season.winter:
        return Icon(Icons.ac_unit, size: widget.size, color: Colors.white);
      default:
        return Container();
    }
  }
}

// Leaderboard widget
class FriendsLeaderboard extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const FriendsLeaderboard({
    super.key,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onExpandToggle,
        child: Container(
          height: isExpanded ? MediaQuery.of(context).size.height * 0.6 : 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 2),
                child: Text(
                  'Leaderboard',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isExpanded
                    ? asyncPets.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) =>
                            const Text('Error fetching pets'),
                        data: (pets) {
                          final petsWithSteps = pets
                              .map((pet) {
                                final asyncWalks =
                                    ref.watch(eventWalksProvider);
                                return asyncWalks.when(
                                  loading: () => null,
                                  error: (err, stack) => null,
                                  data: (walks) {
                                    final totalSteps = walks
                                        .where((walk) => walk!.petId == pet.id)
                                        .fold(0.0,
                                            (sum, walk) => sum + walk!.steps);
                                    return {'pet': pet, 'steps': totalSteps};
                                  },
                                );
                              })
                              .whereType<Map<String, dynamic>>()
                              .where((petWithSteps) =>
                                  petWithSteps['steps'] >= 100)
                              .toList();

                          petsWithSteps
                              .sort((a, b) => b['steps'].compareTo(a['steps']));

                          return Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: petsWithSteps.length,
                              itemBuilder: (context, index) {
                                final user = FirebaseAuth
                                        .instance.currentUser?.displayName ??
                                    'User';
                                final steps = petsWithSteps[index]['steps'];
                                final petName =
                                    petsWithSteps[index]['pet'].name;
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: Text(
                                        '#${index + 1}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      title: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: AssetImage(
                                                petsWithSteps[index]['pet']
                                                    .avatarImage),
                                            radius: 25,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text('Owner: ',
                                                          style: TextStyle(
                                                              fontSize: 11)),
                                                      Text(user,
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Text('Pupil: ',
                                                          style: TextStyle(
                                                              fontSize: 11)),
                                                      Text('$petName',
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text('Steps: ',
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                              Text('$steps',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      onTap: () {},
                                    ),
                                    Divider(
                                        color: const Color(0xff68a2b6)
                                            .withOpacity(0.2)),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Achievement Widget
class AchievementWidget extends StatefulWidget {
  final String achievementName;
  final int currentSteps;
  final int totalSteps;
  final String assetPath;

  const AchievementWidget({
    super.key,
    required this.achievementName,
    required this.currentSteps,
    required this.totalSteps,
    required this.assetPath,
  });

  @override
  createState() => _AchievementWidgetState();
}

class _AchievementWidgetState extends State<AchievementWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Animated achievement image
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.2 + (_animation.value * 0.2),
                  child: child,
                );
              },
              child: Image.asset(
                widget.assetPath,
                height: 175,
                width: 175,
              ),
            ),
            const SizedBox(height: 20),
            // Animated opacity for the achievement name
            AnimatedOpacity(
              opacity: _isExpanded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 600),
              child: Text(
                widget.achievementName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🏆 ${widget.achievementName}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '🚶 Steps: ${widget.currentSteps} / ${widget.totalSteps}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '⏳ Remaining: ${widget.totalSteps - widget.currentSteps}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
