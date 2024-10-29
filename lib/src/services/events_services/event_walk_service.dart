// ignore_for_file: avoid_types_as_parameter_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/pet_achievement.dart';
import 'package:pet_diary/src/components/achievement_widgets/initialize_achievements.dart';
import 'package:uuid/uuid.dart';

class EventWalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final StreamController<List<EventWalkModel>> _walksController =
      StreamController<List<EventWalkModel>>.broadcast();

  EventWalkService() {
    _initWalksStream();
  }

  void _initWalksStream() {
    if (_currentUser != null) {
      _firestore
          .collection('event_walks')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        final allWalks = snapshot.docs
            .map((doc) => EventWalkModel.fromDocument(doc))
            .toList();
        _walksController.add(allWalks);
      });
    }
  }

  Stream<List<EventWalkModel>> getWalksForPet(String userId, String petId) {
    return _firestore
        .collection('event_walks')
        .where('userId', isEqualTo: userId)
        .where('petId', isEqualTo: petId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventWalkModel.fromDocument(doc))
            .toList());
  }

  Stream<List<EventWalkModel>> getWalksForUserPet() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('event_walks')
        .where('userId', isEqualTo: _currentUser.uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventWalkModel.fromDocument(doc))
            .toList());
  }

  Stream<List<EventWalkModel>> getWalksStream() => _walksController.stream;

  Future<EventWalkModel?> getWalkById(String petId, String walkId) async {
    if (_currentUser == null) return null;

    final docSnapshot =
        await _firestore.collection('event_walks').doc(walkId).get();

    return docSnapshot.exists ? EventWalkModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addWalk(String petId, EventWalkModel walk) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('event_walks')
        .doc(walk.id)
        .set({...walk.toMap(), 'userId': _currentUser.uid, 'petId': petId});

    await _checkAndAwardAchievements(petId, walk);
  }

  Future<void> _checkAndAwardAchievements(
      String petId, EventWalkModel walk) async {
    await _checkGeneralAchievements(petId);
    await _checkSeasonalAchievements(petId, walk);
  }

  Future<void> _checkGeneralAchievements(String petId) async {
    final petWalksSnapshot = await _firestore
        .collection('event_walks')
        .where('userId', isEqualTo: _currentUser!.uid)
        .where('petId', isEqualTo: petId)
        .get();

    double totalSteps = petWalksSnapshot.docs
        .fold(0.0, (sum, doc) => sum + EventWalkModel.fromDocument(doc).steps);

    final petAchievementsSnapshot = await _firestore
        .collection('pet_achievements')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('petId', isEqualTo: petId)
        .get();

    final achievedIds = petAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();

    for (var achievement in achievements) {
      if (achievement.category != 'seasonal' &&
          !achievedIds.contains(achievement.id) &&
          totalSteps >= achievement.stepsRequired) {
        final petAchievement = PetAchievement(
          id: const Uuid().v4(),
          userId: _currentUser.uid,
          petId: petId,
          achievementId: achievement.id,
          achievedAt: DateTime.now(),
        );

        await _firestore
            .collection('pet_achievements')
            .doc(petAchievement.id)
            .set(petAchievement.toMap());
      }
    }
  }

  Future<void> _checkSeasonalAchievements(
      String petId, EventWalkModel walk) async {
    final DateTime now = DateTime.now();
    final String currentMonthYear =
        '${now.month.toString().padLeft(2, '0')}_${now.year}';

    final petWalksSnapshot = await _firestore
        .collection('event_walks')
        .where('userId', isEqualTo: _currentUser!.uid)
        .where('petId', isEqualTo: petId)
        .where('dateTime',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month, 1))
        .where('dateTime',
            isLessThanOrEqualTo: DateTime(now.year, now.month + 1, 0))
        .get();

    double totalStepsThisMonth = petWalksSnapshot.docs
        .fold(0.0, (sum, doc) => sum + EventWalkModel.fromDocument(doc).steps);

    final petAchievementsSnapshot = await _firestore
        .collection('pet_achievements')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('petId', isEqualTo: petId)
        .get();

    final achievedIds = petAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();

    final seasonalAchievements = achievements
        .where((achievement) =>
            achievement.category == 'seasonal' &&
            achievement.monthYear == currentMonthYear)
        .toList();

    for (var achievement in seasonalAchievements) {
      if (!achievedIds.contains(achievement.id) &&
          totalStepsThisMonth >= achievement.stepsRequired) {
        final petAchievement = PetAchievement(
          id: const Uuid().v4(),
          userId: _currentUser.uid,
          petId: petId,
          achievementId: achievement.id,
          achievedAt: DateTime.now(),
        );

        await _firestore
            .collection('pet_achievements')
            .doc(petAchievement.id)
            .set(petAchievement.toMap());
      }
    }
  }

  Future<void> updateWalk(String walkId, EventWalkModel walk) async {
    if (_currentUser == null) return;
    await _firestore.collection('event_walks').doc(walkId).update(walk.toMap());
  }

  Future<void> deleteWalk(String walkId) async {
    if (_currentUser == null) return;
    await _firestore.collection('event_walks').doc(walkId).delete();
  }

  void dispose() {
    _walksController.close();
  }
}
