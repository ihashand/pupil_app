import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/services/event_walk_service.dart';

class WalkScreen extends ConsumerStatefulWidget {
  const WalkScreen({super.key});

  @override
  ConsumerState<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends ConsumerState<WalkScreen> {
  late TextEditingController searchController;
  String searchQuery = '';
  Map<String, bool> expandedEvents = {};

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  void _selectDog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Dog'),
          content: Consumer(
            builder: (context, ref, _) {
              final asyncPets = ref.watch(petsProvider);
              return asyncPets.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Error fetching pets'),
                data: (pets) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final currentPet = pets[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(currentPet.avatarImage),
                        ),
                        title: Text(currentPet.name),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    WalkStartScreen(pet: currentPet)),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        title: Text(
          'W A L K',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          const Expanded(
            child: MapWidget(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _selectDog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdfd785),
                minimumSize: const Size(350, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Start Walk',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ),
          const FriendsLeaderboard(),
        ],
      ),
    );
  }
}

class MapWidget extends ConsumerWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);

    return asyncPets.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => const Text('Error loading map'),
      data: (pets) {
        final petsWithSteps = pets
            .map((pet) {
              final asyncWalks = ref.watch(eventWalksProvider);
              return asyncWalks.when(
                loading: () => null,
                error: (err, stack) => null,
                data: (walks) {
                  final totalSteps = walks
                      .where((walk) => walk!.petId == pet.id)
                      .fold(0.0, (sum, walk) => sum + walk!.steps);
                  return {'pet': pet, 'steps': totalSteps};
                },
              );
            })
            .whereType<Map<String, dynamic>>()
            .where((petWithSteps) => petWithSteps['steps'] >= 100)
            .toList();

        if (petsWithSteps.isEmpty) return Container();

        final maxStepsPet = petsWithSteps
            .reduce((a, b) => a['steps'] > b['steps'] ? a : b)['pet'];

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/green_wallpaper.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: CustomPaint(
            painter: PathPainter(),
            size: Size.infinite,
            child: Stack(
              children: [
                ..._buildUserAvatarOnPath(maxStepsPet, petsWithSteps),
                const PositionedMarker(
                  position: Offset(120, 70),
                  steps: 10000,
                  icon: Icons.directions_walk,
                ),
                const PositionedMarker(
                  position: Offset(60, 195),
                  steps: 20000,
                  icon: Icons.directions_walk,
                ),
                const PositionedMarker(
                  position: Offset(165, 270),
                  steps: 50000,
                  icon: Icons.directions_walk,
                ),
                const PositionedMarker(
                  position: Offset(265, 170),
                  steps: 70000,
                  icon: Icons.directions_walk,
                ),
                const PositionedMarker(
                  position: Offset(355, 50),
                  steps: 100000,
                  icon: Icons.flag,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildUserAvatarOnPath(
      Pet maxStepsPet, List<Map<String, dynamic>> petsWithSteps) {
    final userPosition = _getPositionForSteps(
        petsWithSteps.firstWhere((p) => p['pet'] == maxStepsPet)['steps']);

    return [
      Positioned(
        left: userPosition.dx,
        top: userPosition.dy,
        child: CircleAvatar(
          backgroundImage: AssetImage(maxStepsPet.avatarImage),
        ),
      ),
    ];
  }

  Offset _getPositionForSteps(double steps) {
    final List<Map<String, dynamic>> stepPositions = [
      {'steps': 0, 'position': const Offset(0, 20)},
      {'steps': 2500, 'position': const Offset(10, 20)},
      {'steps': 5000, 'position': const Offset(65, 20)},
      {'steps': 7500, 'position': const Offset(120, 20)},
      {'steps': 10000, 'position': const Offset(75, 70)},
      {'steps': 12500, 'position': const Offset(120, 110)},
      {'steps': 15000, 'position': const Offset(200, 120)},
      {'steps': 17500, 'position': const Offset(200, 190)},
      {'steps': 20000, 'position': const Offset(130, 190)},
      {'steps': 22500, 'position': const Offset(15, 195)},
      {'steps': 25000, 'position': const Offset(15, 233)},
      {'steps': 27500, 'position': const Offset(15, 270)},
      {'steps': 30000, 'position': const Offset(25, 270)},
      {'steps': 32500, 'position': const Offset(45, 270)},
      {'steps': 35000, 'position': const Offset(70, 270)},
      {'steps': 37500, 'position': const Offset(85, 270)},
      {'steps': 40000, 'position': const Offset(100, 270)},
      {'steps': 42500, 'position': const Offset(110, 270)},
      {'steps': 45000, 'position': const Offset(125, 270)},
      {'steps': 47500, 'position': const Offset(130, 270)},
      {'steps': 50000, 'position': const Offset(165, 230)},
      {'steps': 52500, 'position': const Offset(190, 270)},
      {'steps': 55000, 'position': const Offset(210, 270)},
      {'steps': 57500, 'position': const Offset(230, 270)},
      {'steps': 60000, 'position': const Offset(250, 270)},
      {'steps': 62500, 'position': const Offset(265, 255)},
      {'steps': 65000, 'position': const Offset(265, 230)},
      {'steps': 67500, 'position': const Offset(265, 200)},
      {'steps': 70000, 'position': const Offset(305, 170)},
      {'steps': 72500, 'position': const Offset(265, 135)},
      {'steps': 75000, 'position': const Offset(265, 125)},
      {'steps': 77500, 'position': const Offset(265, 115)},
      {'steps': 80000, 'position': const Offset(265, 105)},
      {'steps': 82500, 'position': const Offset(265, 95)},
      {'steps': 85000, 'position': const Offset(265, 85)},
      {'steps': 87500, 'position': const Offset(265, 75)},
      {'steps': 90000, 'position': const Offset(265, 50)},
      {'steps': 92500, 'position': const Offset(295, 50)},
      {'steps': 95000, 'position': const Offset(315, 50)},
      {'steps': 97500, 'position': const Offset(330, 50)},
      {'steps': 100000, 'position': const Offset(355, 10)},
    ];

    for (int i = 0; i < stepPositions.length - 1; i++) {
      if (steps >= stepPositions[i]['steps'] &&
          steps < stepPositions[i + 1]['steps']) {
        double ratio = (steps - stepPositions[i]['steps']) /
            (stepPositions[i + 1]['steps'] - stepPositions[i]['steps']);
        return Offset(
          stepPositions[i]['position'].dx +
              ratio *
                  (stepPositions[i + 1]['position'].dx -
                      stepPositions[i]['position'].dx),
          stepPositions[i]['position'].dy +
              ratio *
                  (stepPositions[i + 1]['position'].dy -
                      stepPositions[i]['position'].dy),
        );
      }
    }
    return stepPositions.last['position'];
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintFill = Paint()
      ..color = const Color.fromARGB(0, 255, 255, 255)
      ..style = PaintingStyle.fill;

    Paint paintStroke = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel;

    Path path = Path();
    path.moveTo(size.width * -0.0176500, size.height * 0.1242500);
    path.quadraticBezierTo(size.width * 0.2174000, size.height * 0.1237500,
        size.width * 0.2957500, size.height * 0.1238500);
    path.quadraticBezierTo(size.width * 0.3502750, size.height * 0.1326250,
        size.width * 0.3582000, size.height * 0.1748500);
    path.quadraticBezierTo(size.width * 0.3570750, size.height * 0.3152500,
        size.width * 0.3570000, size.height * 0.3604750);
    path.quadraticBezierTo(size.width * 0.3559000, size.height * 0.4024750,
        size.width * 0.3933750, size.height * 0.4077250);
    path.quadraticBezierTo(size.width * 0.4842000, size.height * 0.4079312,
        size.width * 0.5144750, size.height * 0.4080000);
    path.quadraticBezierTo(size.width * 0.5587750, size.height * 0.4124000,
        size.width * 0.5683750, size.height * 0.4474500);
    path.quadraticBezierTo(size.width * 0.5682750, size.height * 0.5581000,
        size.width * 0.5686500, size.height * 0.5951500);
    path.quadraticBezierTo(size.width * 0.5660000, size.height * 0.6406250,
        size.width * 0.5182500, size.height * 0.6421750);
    path.quadraticBezierTo(size.width * 0.2295000, size.height * 0.6411000,
        size.width * 0.1346250, size.height * 0.6411250);
    path.quadraticBezierTo(size.width * 0.0960250, size.height * 0.6473750,
        size.width * 0.0926750, size.height * 0.6867500);
    path.quadraticBezierTo(size.width * 0.0936000, size.height * 0.7824000,
        size.width * 0.0929250, size.height * 0.8142750);
    path.quadraticBezierTo(size.width * 0.0980250, size.height * 0.8526500,
        size.width * 0.1442000, size.height * 0.8592500);
    path.quadraticBezierTo(size.width * 0.5416250, size.height * 0.8596063,
        size.width * 0.6741000, size.height * 0.8597250);
    path.quadraticBezierTo(size.width * 0.7201750, size.height * 0.8521500,
        size.width * 0.7247000, size.height * 0.8168750);
    path.quadraticBezierTo(size.width * 0.7249250, size.height * 0.3954687,
        size.width * 0.7250000, size.height * 0.2550000);
    path.quadraticBezierTo(size.width * 0.7251250, size.height * 0.2105000,
        size.width * 0.7682000, size.height * 0.2079500);
    path.lineTo(size.width * 1.0145250, size.height * 0.2079750);

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PositionedMarker extends StatelessWidget {
  final Offset position;
  final int steps;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final double circleSize;

  const PositionedMarker({
    super.key,
    required this.position,
    required this.steps,
    required this.icon,
    this.backgroundColor = Colors.yellow,
    this.iconColor = Colors.white,
    this.iconSize = 24.0,
    this.circleSize = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Milestone'),
                content: Text('Steps to go: $steps'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        },
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          radius: circleSize / 2,
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}

class FriendsLeaderboard extends ConsumerWidget {
  const FriendsLeaderboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);

    return asyncPets.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => const Text('Error fetching pets'),
      data: (pets) {
        final petsWithSteps = pets
            .map((pet) {
              final asyncWalks = ref.watch(eventWalksProvider);
              return asyncWalks.when(
                loading: () => null,
                error: (err, stack) => null,
                data: (walks) {
                  final totalSteps = walks
                      .where((walk) => walk!.petId == pet.id)
                      .fold(0.0, (sum, walk) => sum + walk!.steps);
                  return {'pet': pet, 'steps': totalSteps};
                },
              );
            })
            .whereType<Map<String, dynamic>>()
            .where((petWithSteps) => petWithSteps['steps'] >= 100)
            .toList();

        petsWithSteps.sort((a, b) => b['steps'].compareTo(a['steps']));

        return Expanded(
          child: ListView.builder(
            itemCount: petsWithSteps.length,
            itemBuilder: (context, index) {
              final user = FirebaseAuth.instance.currentUser?.displayName;
              final steps = petsWithSteps[index]['steps'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      AssetImage(petsWithSteps[index]['pet'].avatarImage),
                ),
                title: Text('User ${user}'),
                subtitle: Text('Steps this month: $steps'),
                trailing: Text('#${index + 1}'),
                onTap: () {
                  // Navigate to user profile screen if needed
                },
              );
            },
          ),
        );
      },
    );
  }
}

class WalkStartScreen extends StatefulWidget {
  final Pet pet;

  const WalkStartScreen({super.key, required this.pet});

  @override
  createState() => _WalkStartScreenState();
}

class _WalkStartScreenState extends State<WalkStartScreen> {
  late Timer _timer;
  int _seconds = 0;
  int _steps = 0;
  double _calories = 0.0;
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _steps++;
        _calories += 0.05;
        _distance += 0.01;
      });
    });
  }

  void _stopWalk() {
    _timer.cancel();
    final walkService = EventWalkService();
    final eventWalk = EventWalkModel(
      id: '',
      walkTime: _seconds.toDouble(),
      eventId: '',
      petId: widget.pet.id,
      steps: _steps.toDouble(),
      dateTime: DateTime.now(),
    );
    walkService.addWalk(eventWalk);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Walking with ${widget.pet.name}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WalkStats(
              time: _seconds,
              steps: _steps,
              calories: _calories,
              distance: _distance,
            ),
            ElevatedButton(
              onPressed: _stopWalk,
              child: const Text('Stop Walk'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkStats extends StatelessWidget {
  final int time;
  final int steps;
  final double calories;
  final double distance;

  const WalkStats({
    super.key,
    required this.time,
    required this.steps,
    required this.calories,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Time: ${_formatTime(time)}'),
        Text('Steps: $steps'),
        Text('Calories: ${calories.toStringAsFixed(2)} kcal'),
        Text('Distance: ${distance.toStringAsFixed(2)} km'),
      ],
    );
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class PetProfileScreen extends StatelessWidget {
  final Pet pet;

  const PetProfileScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: AssetImage(pet.avatarImage),
                radius: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text('Name: ${pet.name}', style: const TextStyle(fontSize: 20)),
            Text('Age: ${pet.age}', style: const TextStyle(fontSize: 16)),
            Text('Gender: ${pet.gender}', style: const TextStyle(fontSize: 16)),
            Text('Breed: ${pet.breed}', style: const TextStyle(fontSize: 16)),
            Consumer(
              builder: (context, ref, _) {
                final asyncWalks = ref.watch(eventWalksProvider);
                return asyncWalks.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => const Text('Error loading steps'),
                  data: (walks) {
                    final totalSteps = walks
                        .where((walk) => walk!.petId == pet.id)
                        .fold(0.0, (sum, walk) => sum + walk!.steps);
                    return Text('Steps this month: $totalSteps',
                        style: const TextStyle(fontSize: 16));
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Rewards:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class Reward {
  final String title;
  final String description;
  final int stepsThreshold;

  Reward(
      {required this.title,
      required this.description,
      required this.stepsThreshold});
}

final List<Reward> rewards = [
  Reward(
      title: 'Bronze Medal',
      description: 'Walk 1000 steps',
      stepsThreshold: 1000),
  Reward(
      title: 'Silver Medal',
      description: 'Walk 5000 steps',
      stepsThreshold: 5000),
  Reward(
      title: 'Gold Medal',
      description: 'Walk 10000 steps',
      stepsThreshold: 10000),
];

List<Reward> getRewardsForSteps(double steps) {
  return rewards.where((reward) => steps >= reward.stepsThreshold).toList();
}

// Placeholder providers for time, steps, calories, and distance
final timeProvider = StateProvider<String>((ref) => '00:00:00');
final stepsProvider = StateProvider<int>((ref) => 0);
final caloriesProvider = StateProvider<int>((ref) => 0);
final distanceProvider = StateProvider<double>((ref) => 0.0);
