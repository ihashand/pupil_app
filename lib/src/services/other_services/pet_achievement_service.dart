import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/pet_achievement.dart';

class PetAchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // StreamController for managing pet achievements stream
  final StreamController<List<PetAchievement>> _achievementsController =
      StreamController<List<PetAchievement>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Get a stream of pet achievements for a specific pet.
  Stream<List<PetAchievement>> getPetAchievementsStream(String petId) {
    try {
      final subscription = _firestore
          .collection('pet_achievements')
          .where('petId', isEqualTo: petId)
          .snapshots()
          .listen(
        (snapshot) {
          final achievements = snapshot.docs
              .map((doc) => PetAchievement.fromDocument(doc))
              .toList();
          _achievementsController.add(achievements);
        },
        onError: (error) {
          debugPrint('Error fetching pet achievements stream: $error');
          _achievementsController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _achievementsController.stream;
    } catch (e) {
      debugPrint('Error in getPetAchievementsStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetch all achievements for a specific pet as a one-time operation.
  Future<List<PetAchievement>> getPetAchievements(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('pet_achievements')
          .where('petId', isEqualTo: petId)
          .get();

      return snapshot.docs
          .map((doc) => PetAchievement.fromDocument(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching pet achievements: $e');
      throw Exception('Failed to fetch pet achievements');
    }
  }

  /// Add a new achievement for a pet.
  Future<void> addPetAchievement(PetAchievement petAchievement) async {
    try {
      await _firestore
          .collection('pet_achievements')
          .doc(petAchievement.id)
          .set(petAchievement.toMap());
    } catch (e) {
      debugPrint('Error adding pet achievement: $e');
      throw Exception('Failed to add pet achievement');
    }
  }

  /// Update an existing pet achievement.
  Future<void> updatePetAchievement(PetAchievement petAchievement) async {
    try {
      await _firestore
          .collection('pet_achievements')
          .doc(petAchievement.id)
          .update(petAchievement.toMap());
    } catch (e) {
      debugPrint('Error updating pet achievement: $e');
      throw Exception('Failed to update pet achievement');
    }
  }

  /// Delete a pet achievement by ID.
  Future<void> deletePetAchievement(String achievementId) async {
    try {
      await _firestore
          .collection('pet_achievements')
          .doc(achievementId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting pet achievement: $e');
      throw Exception('Failed to delete pet achievement');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _achievementsController.close();
  }
}
