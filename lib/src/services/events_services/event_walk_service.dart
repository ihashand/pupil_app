import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
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

  Stream<List<EventWalkModel>> getWalksForPet(String petId) {
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
    // Sprawdzenie achievementów ogólnych
    await _checkGeneralAchievements(petId);

    // Sprawdzenie achievementów sezonowych
    await _checkSeasonalAchievements(petId, walk);
  }

  Future<void> _checkGeneralAchievements(String petId) async {
    // Pobierz wszystkie spacery zwierzaka
    final petWalksSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .get();

    double totalSteps = 0;

    for (var doc in petWalksSnapshot.docs) {
      totalSteps += EventWalkModel.fromDocument(doc).steps;
    }

    // Pobierz osiągnięcia zwierzaka
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

    // Sprawdź, które achievementy ogólne mogą być przyznane
    List<Achievement> generalAchievements = achievements.where((achievement) {
      return achievement.category == 'general' &&
          !achievedIds.contains(achievement.id) &&
          totalSteps >= achievement.stepsRequired;
    }).toList();

    // Przyznaj nowe osiągnięcia
    for (var achievement in generalAchievements) {
      final petAchievement = PetAchievement(
        id: const Uuid().v4(),
        userId: _currentUser.uid,
        petId: petId,
        achievementId: achievement.id,
        achievedAt: DateTime.now(),
      );

      await _firestore
          .collection('app_users')
          .doc(_currentUser.uid)
          .collection('pets')
          .doc(petId)
          .collection('pet_achievements')
          .doc(petAchievement.id)
          .set(petAchievement.toMap());
    }
  }

  Future<void> _checkSeasonalAchievements(
      String petId, EventWalkModel walk) async {
    final DateTime now = DateTime.now();
    final int currentMonth = now.month;

    // Pobierz spacery zwierzaka z bieżącego miesiąca
    final petWalksSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks')
        .where('dateTime',
            isGreaterThanOrEqualTo: DateTime(now.year, currentMonth, 1))
        .get();

    double totalStepsThisMonth = 0;

    for (var doc in petWalksSnapshot.docs) {
      totalStepsThisMonth += EventWalkModel.fromDocument(doc).steps;
    }

    // Pobierz osiągnięcia zwierzaka
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

    // Sprawdź, które achievementy sezonowe mogą być przyznane
    List<Achievement> seasonalAchievements = achievements.where((achievement) {
      return achievement.category == 'seasonal' &&
          !achievedIds.contains(achievement.id) &&
          totalStepsThisMonth >= achievement.stepsRequired;
    }).toList();

    // Przyznaj nowe osiągnięcia
    for (var achievement in seasonalAchievements) {
      final petAchievement = PetAchievement(
        id: const Uuid().v4(),
        userId: _currentUser.uid,
        petId: petId,
        achievementId: achievement.id,
        achievedAt: DateTime.now(),
      );

      await _firestore
          .collection('app_users')
          .doc(_currentUser.uid)
          .collection('pets')
          .doc(petId)
          .collection('pet_achievements')
          .doc(petAchievement.id)
          .set(petAchievement.toMap());
    }
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
