import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/user_achievement.dart';
import 'package:pet_diary/src/components/widgets_todo_task_foldery/achievement_widgets/initialize_achievements.dart';
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
    // Pobierz wszystkie spacery psa
    final petWalksSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_walks')
        .where('petId', isEqualTo: walk.petId)
        .get();

    double totalSteps = 0;

    // Zsumuj kroki ze wszystkich spacerów
    for (var doc in petWalksSnapshot.docs) {
      totalSteps += EventWalkModel.fromDocument(doc).steps;
    }

    // Pobierz osiągnięcia, które pies już zdobył
    final userAchievementsSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('user_achievements')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('petId', isEqualTo: walk.petId)
        .get();

    // Zbierz ID osiągnięć, które już zostały przyznane
    final achievedIds = userAchievementsSnapshot.docs
        .map((doc) => doc.get('achievementId') as String)
        .toSet();

    // Sprawdź i przyznaj nowe osiągnięcia z predefiniowanej listy
    for (var achievement in achievements) {
      // Sprawdź, czy pies nie zdobył jeszcze tego osiągnięcia
      if (!achievedIds.contains(achievement.id) &&
          totalSteps >= achievement.stepsRequired) {
        final userAchievement = UserAchievement(
          id: const Uuid().v4(),
          userId: _currentUser.uid,
          petId: walk.petId,
          achievementId: achievement.id,
          achievedAt: DateTime.now(),
        );

        // Przyznaj nowe osiągnięcie
        await _firestore
            .collection('app_users')
            .doc(_currentUser.uid)
            .collection('user_achievements')
            .doc(userAchievement.id)
            .set(userAchievement.toMap());

        // Dodaj osiągnięcie do listy przyznanych, aby nie przyznawać go ponownie
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
