import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/achievement.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/models/user_achievement.dart';
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

    // Dodaj spacer do bazy danych
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walk.id)
        .set(walk.toMap());

    // Sprawdź osiągnięcia
    await _checkAndAwardAchievements(walk);
  }

  Future<void> _checkAndAwardAchievements(EventWalkModel walk) async {
    final petWalks = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_walks')
        .where('petId', isEqualTo: walk.petId)
        .get();

    double totalSteps = walk.steps;

    for (var doc in petWalks.docs) {
      totalSteps += EventWalkModel.fromDocument(doc).steps;
    }

    final achievementsSnapshot =
        await _firestore.collection('achievements').get();
    final achievements = achievementsSnapshot.docs
        .map((doc) => Achievement.fromDocument(doc))
        .toList();

    for (var achievement in achievements) {
      if (totalSteps >= achievement.stepsRequired) {
        // Sprawdź, czy pies już zdobył to osiągnięcie
        final userAchievementsSnapshot = await _firestore
            .collection('user_achievements')
            .where('userId', isEqualTo: _currentUser.uid)
            .where('petId', isEqualTo: walk.petId)
            .where('achievementId', isEqualTo: achievement.id)
            .get();

        if (userAchievementsSnapshot.docs.isEmpty) {
          // Przyznaj nowe osiągnięcie
          final userAchievement = UserAchievement(
            id: const Uuid().v4(),
            userId: _currentUser.uid,
            petId: walk.petId,
            achievementId: achievement.id,
            achievedAt: DateTime.now(),
          );

          await _firestore
              .collection('user_achievements')
              .doc(userAchievement.id)
              .set(userAchievement.toMap());
        }
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
