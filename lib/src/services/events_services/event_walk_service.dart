import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/models/others/user_achievement.dart';
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
          .collection('event_walks')
          .orderBy('dateTime', descending: true)
          .snapshots()
          .listen((snapshot) {
        final walks = snapshot.docs
            .map((doc) => EventWalkModel.fromDocument(doc))
            .toList();
        _walksController.add(walks);
      });
    }
  }

  Stream<List<EventWalkModel>> getWalksFriend(String uid) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(uid)
        .collection('event_walks')
        .snapshots()
        .listen((snapshot) {
      _walksController.add(snapshot.docs
          .map((doc) => EventWalkModel.fromDocument(doc))
          .toList());
    });

    return _walksController.stream;
  }

  Stream<List<EventWalkModel>> getWalksStream() => _walksController.stream;

  Future<EventWalkModel?> getWalkById(String walkId) async {
    if (_currentUser == null) return null;

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walkId)
        .get();

    return docSnapshot.exists ? EventWalkModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addWalk(EventWalkModel walk) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walk.id)
        .set(walk.toMap());

    await _checkAndAwardAchievements(walk);
  }

  Future<void> _checkAndAwardAchievements(EventWalkModel walk) async {
    final DateTime now = DateTime.now();
    final int currentMonth = now.month;

    // Zmodyfikuj zapytanie, aby uwzględnić tylko spacery z bieżącego miesiąca
    final petWalksSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_walks')
        .where('petId', isEqualTo: walk.petId)
        .where('dateTime',
            isGreaterThanOrEqualTo: DateTime(now.year, currentMonth, 1))
        .get();

    double totalStepsThisMonth = 0;

    for (var doc in petWalksSnapshot.docs) {
      totalStepsThisMonth += EventWalkModel.fromDocument(doc).steps;
    }

    // Pobierz aktualne osiągnięcia użytkownika
    final userAchievementsSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('user_achievements')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('petId', isEqualTo: walk.petId)
        .get();

    final achievedIds = userAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();

    // Sprawdź, czy użytkownik osiągnął sezonowy achievement
    // Tworzymy nową listę osiągnięć sezonowych
    List<Achievement> seasonalAchievements = achievements.where((achievement) {
      return achievement.category == 'seasonal' &&
          !achievedIds.contains(achievement.id) &&
          totalStepsThisMonth >= achievement.stepsRequired;
    }).toList();

    for (var achievement in seasonalAchievements) {
      // Logika przyznania osiągnięcia
      final userAchievement = UserAchievement(
        id: const Uuid().v4(),
        userId: _currentUser.uid,
        petId: walk.petId,
        achievementId: achievement.id,
        achievedAt: DateTime.now(),
      );

      await _firestore
          .collection('app_users')
          .doc(_currentUser.uid)
          .collection('user_achievements')
          .doc(userAchievement.id)
          .set(userAchievement.toMap());

      achievedIds.add(achievement.id);
    }

    // Standardowa logika przyznawania innych osiągnięć
    for (var achievement in achievements) {
      if (!achievedIds.contains(achievement.id) &&
          totalStepsThisMonth >= achievement.stepsRequired) {
        final userAchievement = UserAchievement(
          id: const Uuid().v4(),
          userId: _currentUser.uid,
          petId: walk.petId,
          achievementId: achievement.id,
          achievedAt: DateTime.now(),
        );

        await _firestore
            .collection('app_users')
            .doc(_currentUser.uid)
            .collection('user_achievements')
            .doc(userAchievement.id)
            .set(userAchievement.toMap());

        achievedIds.add(achievement.id);
      }
    }
  }

  Future<void> updateWalk(EventWalkModel walk) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walk.id)
        .update(walk.toMap());
  }

  Future<void> deleteWalk(String walkId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walkId)
        .delete();
  }

  void dispose() {
    _walksController.close();
  }
}
