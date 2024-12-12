import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/pet_achievement.dart';

class PetAchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _achievementsSubscription;
  final StreamController<List<PetAchievement>> _achievementsController =
      StreamController<List<PetAchievement>>.broadcast();

  /// Get a stream of pet achievements for a specific pet.
  Stream<List<PetAchievement>> getPetAchievementsStream(String petId) {
    _achievementsSubscription = _firestore
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

    return _achievementsController.stream;
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

  /// Cancel active subscription to achievements.
  void cancelSubscription() {
    _achievementsSubscription?.cancel();
  }

  /// Dispose the service by closing the stream controller.
  void dispose() {
    cancelSubscription();
    _achievementsController.close();
  }
}
