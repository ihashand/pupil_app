import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/pet_achievement.dart';
import 'package:pet_diary/src/components/achievement_widgets/initialize_achievements.dart';
import 'package:uuid/uuid.dart';

class EventWalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting walk events stream
  final StreamController<List<EventWalkModel>> _walksController =
      StreamController<List<EventWalkModel>>.broadcast();

  // Cache for fetched walks
  List<EventWalkModel>? _cachedWalks;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  EventWalkService() {
    _initWalksStream();
  }

  void _initWalksStream() {
    if (_currentUser != null) {
      final subscription = _firestore
          .collection('event_walks')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        final allWalks = snapshot.docs
            .map((doc) => EventWalkModel.fromDocument(doc))
            .toList();
        _cachedWalks = allWalks;
        _lastFetchTime = DateTime.now();
        _walksController.add(allWalks);
      }, onError: (error) {
        debugPrint('Error initializing walks stream: $error');
        _walksController.addError(error);
      });

      _subscriptions.add(subscription);
    }
  }

  Stream<List<EventWalkModel>> getWalksForPet(String userId, String petId) {
    try {
      return _firestore
          .collection('event_walks')
          .where('userId', isEqualTo: userId)
          .where('petId', isEqualTo: petId)
          .orderBy('dateTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EventWalkModel.fromDocument(doc))
              .toList());
    } catch (e) {
      debugPrint('Error fetching walks for pet: $e');
      return Stream.error(e);
    }
  }

  Stream<List<EventWalkModel>> getWalksForUserPet() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('event_walks')
          .where('userId', isEqualTo: _currentUser.uid)
          .orderBy('dateTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EventWalkModel.fromDocument(doc))
              .toList());
    } catch (e) {
      debugPrint('Error fetching walks for user pet: $e');
      return Stream.error(e);
    }
  }

  Stream<List<EventWalkModel>> getWalksStream() {
    try {
      if (_cachedWalks != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _walksController.add(_cachedWalks!);
      }

      return _walksController.stream;
    } catch (e) {
      debugPrint('Error fetching walks stream: $e');
      return Stream.error(e);
    }
  }

  Future<EventWalkModel?> getWalkById(String petId, String walkId) async {
    if (_currentUser == null) return null;

    try {
      final docSnapshot =
          await _firestore.collection('event_walks').doc(walkId).get();

      return docSnapshot.exists
          ? EventWalkModel.fromDocument(docSnapshot)
          : null;
    } catch (e) {
      debugPrint('Error fetching walk by ID: $e');
      return null;
    }
  }

  Future<void> addWalk(String petId, EventWalkModel walk) async {
    if (_currentUser == null) return;

    try {
      await _firestore
          .collection('event_walks')
          .doc(walk.id)
          .set({...walk.toMap(), 'userId': _currentUser.uid, 'petId': petId});

      _cachedWalks = null; // Invalidate cache after adding
      await _checkAndAwardAchievements(petId, walk);
    } catch (e) {
      debugPrint('Error adding walk: $e');
    }
  }

  Future<void> _checkAndAwardAchievements(
      String petId, EventWalkModel walk) async {
    try {
      await _checkGeneralAchievements(petId);
      await _checkSeasonalAchievements(petId, walk);
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  Future<void> _checkGeneralAchievements(String petId) async {
    try {
      final petWalksSnapshot = await _firestore
          .collection('event_walks')
          .where('userId', isEqualTo: _currentUser!.uid)
          .where('petId', isEqualTo: petId)
          .get();

      double totalSteps = petWalksSnapshot.docs.fold(
          // ignore: avoid_types_as_parameter_names
          0.0,
          (sum, doc) => sum + EventWalkModel.fromDocument(doc).steps);

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
    } catch (e) {
      debugPrint('Error checking general achievements: $e');
    }
  }

  Future<void> _checkSeasonalAchievements(
      String petId, EventWalkModel walk) async {
    try {
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

      double totalStepsThisMonth = petWalksSnapshot.docs.fold(
          // ignore: avoid_types_as_parameter_names
          0.0,
          (sum, doc) => sum + EventWalkModel.fromDocument(doc).steps);

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
    } catch (e) {
      debugPrint('Error checking seasonal achievements: $e');
    }
  }

  Future<void> updateWalk(String walkId, EventWalkModel walk) async {
    if (_currentUser == null) return;

    try {
      await _firestore
          .collection('event_walks')
          .doc(walkId)
          .update(walk.toMap());
    } catch (e) {
      debugPrint('Error updating walk: $e');
    }
  }

  Future<void> deleteWalk(String walkId) async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('event_walks').doc(walkId).delete();
      _cachedWalks = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting walk: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _walksController.close();
  }
}
