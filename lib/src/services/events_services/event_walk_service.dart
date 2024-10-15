import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
          .collection('app_users')
          .doc(_currentUser.uid)
          .collection('pets')
          .snapshots()
          .listen((snapshot) {
        final allWalks = <EventWalkModel>[];
        for (var doc in snapshot.docs) {
          _firestore
              .collection('app_users')
              .doc(_currentUser.uid)
              .collection('pets')
              .doc(doc.id)
              .collection('event_walks')
              .snapshots()
              .listen((walksSnapshot) {
            final walks = walksSnapshot.docs
                .map((doc) => EventWalkModel.fromDocument(doc))
                .toList();
            allWalks.addAll(walks);
          });
        }
        _walksController.add(allWalks);
      });
    }
  }

  Stream<List<EventWalkModel>> getWalksForUserPet(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventWalkModel.fromDocument(doc))
          .toList();
    });
  }

  Stream<List<EventWalkModel>> getWalksForPet(String userId, String petId) {
    return _firestore
        .collection('app_users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventWalkModel.fromDocument(doc))
          .toList();
    });
  }

  Stream<List<EventWalkModel>> getWalksStream() => _walksController.stream;

  Future<EventWalkModel?> getWalkById(String petId, String walkId) async {
    if (_currentUser == null) return null;

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .doc(walkId)
        .get();

    return docSnapshot.exists ? EventWalkModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addWalk(String petId, EventWalkModel walk) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .doc(walk.id)
        .set(walk.toMap());

    await _checkAndAwardAchievements(petId, walk);
  }

  Future<void> _checkAndAwardAchievements(
      String petId, EventWalkModel walk) async {
    // Check general achievements
    await _checkGeneralAchievements(petId);

    // Check seasonal achievements
    await _checkSeasonalAchievements(petId, walk);
  }

  Future<void> _checkGeneralAchievements(String petId) async {
    // Fetch all pet walks
    final petWalksSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .get();

    double totalSteps = 0;

    // Zliczamy wszystkie kroki ze spacerów zwierzaka
    for (var doc in petWalksSnapshot.docs) {
      totalSteps += EventWalkModel.fromDocument(doc).steps;
    }

    // Fetch pet achievements to check which achievements are already awarded
    final petAchievementsSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('pet_achievements')
        .get();

    final achievedIds = petAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();

    // Award new achievements based on total steps, excluding seasonal achievements
    for (var achievement in achievements) {
      if (achievement.category != 'seasonal' && // Ignore seasonal achievements
          !achievedIds.contains(achievement.id) &&
          totalSteps >= achievement.stepsRequired) {
        final petAchievement = PetAchievement(
          id: const Uuid().v4(),
          userId: _currentUser.uid,
          petId: petId,
          achievementId: achievement.id,
          achievedAt: DateTime.now(),
        );

        // Add the achievement to pet_achievements
        await _firestore
            .collection('app_users')
            .doc(_currentUser.uid)
            .collection('pets')
            .doc(petId)
            .collection('pet_achievements')
            .doc(petAchievement.id)
            .set(petAchievement.toMap());

        // Add the achievementId to the pet's achievementIds field
        await _addAchievementToPet(petId, achievement.id);
      }
    }
  }

  Future<void> _checkSeasonalAchievements(
      String petId, EventWalkModel walk) async {
    final DateTime now = DateTime.now();
    final String currentMonthYear =
        '${now.month.toString().padLeft(2, '0')}_${now.year}';

    // Pobieramy spacery tylko z bieżącego miesiąca
    final petWalksSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .where('dateTime',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month, 1))
        .where('dateTime',
            isLessThanOrEqualTo: DateTime(now.year, now.month + 1, 0))
        .get();

    double totalStepsThisMonth = 0;

    // Zliczamy kroki tylko z bieżącego miesiąca
    for (var doc in petWalksSnapshot.docs) {
      totalStepsThisMonth += EventWalkModel.fromDocument(doc).steps;
    }

    // Pobieramy osiągnięcia, które już są przyznane zwierzakowi
    final petAchievementsSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('pet_achievements')
        .get();

    final achievedIds = petAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();

    // Filtrowanie sezonowych osiągnięć dla bieżącego miesiąca
    final seasonalAchievements = achievements
        .where((achievement) =>
            achievement.category == 'seasonal' &&
            achievement.monthYear == currentMonthYear)
        .toList();

    // Sprawdzamy, czy osiągnięcie zostało już przyznane
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

        // Add the seasonal achievement to pet_achievements
        await _firestore
            .collection('app_users')
            .doc(_currentUser.uid)
            .collection('pets')
            .doc(petId)
            .collection('pet_achievements')
            .doc(petAchievement.id)
            .set(petAchievement.toMap());

        // Add the achievementId to the pet's achievementIds field
        await _addAchievementToPet(petId, achievement.id);
      }
    }
  }

  Future<void> _addAchievementToPet(String petId, String achievementId) async {
    final petDocRef = _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(petDocRef);

      if (!snapshot.exists) {
        throw Exception("Pet not found");
      }

      List<String> achievementIds =
          List<String>.from(snapshot.data()?['achievementIds'] ?? []);

      if (!achievementIds.contains(achievementId)) {
        achievementIds.add(achievementId);
        transaction.update(petDocRef, {'achievementIds': achievementIds});
      }
    });
  }

  Future<void> updateWalk(String petId, EventWalkModel walk) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .doc(walk.id)
        .update(walk.toMap());
  }

  Future<void> deleteWalk(String petId, String walkId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .doc(walkId)
        .delete();
  }

  void dispose() {
    _walksController.close();
  }
}
