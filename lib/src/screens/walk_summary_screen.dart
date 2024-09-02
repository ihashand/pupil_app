import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/walk_state_provider.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/achievement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:confetti/confetti.dart';

class WalkSummaryScreen extends ConsumerStatefulWidget {
  final List<File> images;
  final WalkState walkState;
  final List<String> petIds; // Lista ID wybranych psów

  const WalkSummaryScreen({
    super.key,
    required this.images,
    required this.walkState,
    required this.petIds,
  });

  @override
  createState() => _WalkSummaryScreenState();
}

class _WalkSummaryScreenState extends ConsumerState<WalkSummaryScreen> {
  ConfettiController? _confettiController;
  List<Achievement> newAchievements = [];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 15));
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  void _showNewAchievementsDialog(List<Achievement> achievements) {
    _confettiController?.play();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              title: const Text('New Achievements!'),
              content: SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementCard(achievement);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController!,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              blastDirection: -pi / 2,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.1,
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

  @override
  Widget build(BuildContext context) {
    final eventWalkService = ref.read(eventWalkServiceProvider);
    final eventService = ref.read(eventServiceProvider);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    for (String petId in widget.petIds) {
      final walkId = const Uuid().v4();
      final eventId = const Uuid().v4();

      final walk = EventWalkModel(
        id: walkId,
        walkTime: widget.walkState.seconds.toDouble(),
        eventId: eventId,
        petId: petId,
        steps: widget.walkState.currentSteps.toDouble(),
        dateTime: DateTime.now(),
        caloriesBurned: widget.walkState.totalCaloriesBurned,
        distance: widget.walkState.totalDistance,
        routePoints: widget.walkState.routePoints,
        images: widget.images.map((image) => image.path).toList(),
      );

      final event = Event(
        id: eventId,
        title: 'Walk',
        eventDate: DateTime.now(),
        dateWhenEventAdded: DateTime.now(),
        userId: userId,
        petId: petId,
        weightId: '',
        temperatureId: '',
        walkId: walkId,
        waterId: '',
        noteId: '',
        pillId: '',
        moodId: '',
        stomachId: '',
        description:
            '${widget.walkState.currentSteps} steps in ${_formatTime(widget.walkState.seconds)}.',
        proffesionId: 'BRAK',
        personId: 'BRAK',
        avatarImage: 'assets/images/dog_avatar_010.png',
        emoticon: '🚶‍➡️',
        psychicId: '',
        stoolId: '',
        urineId: '',
        serviceId: '',
        careId: '',
      );

      // Dodaj spacer do bazy danych
      eventWalkService.addWalk(walk);
      eventService.addEvent(event);
    }

    if (newAchievements.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNewAchievementsDialog(newAchievements);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'W A L K  S U M M A R Y',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 1),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: widget.walkState.routePoints.isNotEmpty
                            ? widget.walkState.routePoints.last
                            : const LatLng(51.5, -0.09),
                        initialZoom: 16.0,
                        minZoom: 5,
                        maxZoom: 25,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                                points: widget.walkState.routePoints,
                                strokeWidth: 15,
                                color: const Color(0xffdfd785)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildSummaryData(context, widget.walkState),
          if (widget.images.isNotEmpty) _buildImageGallery(context),
        ],
      ),
    );
  }

  Widget _buildSummaryData(BuildContext context, WalkState walkState) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryDataRow(context, "Date",
              DateTime.now().toLocal().toString().split(' ')[0]),
          const Divider(color: Colors.grey, height: 20),
          _buildSummaryDataRow(context, "Time", _formatTime(walkState.seconds)),
          const Divider(color: Colors.grey, height: 20),
          _buildSummaryDataRow(
              context, "Steps", walkState.currentSteps.toString()),
          const Divider(color: Colors.grey, height: 20),
          _buildSummaryDataRow(context, "Distance",
              "${walkState.totalDistance.toStringAsFixed(2)} km"),
          const Divider(color: Colors.grey, height: 20),
          _buildSummaryDataRow(context, "Calories Burned",
              "${walkState.totalCaloriesBurned.toStringAsFixed(0)} kcal"),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildSummaryDataRow(
      BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Photos",
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Divider(color: Colors.grey, height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.images.map((image) {
              return GestureDetector(
                onTap: () {
                  _showImageDialog(context, image);
                },
                child: Image.file(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.file(image),
        );
      },
    );
  }
}
