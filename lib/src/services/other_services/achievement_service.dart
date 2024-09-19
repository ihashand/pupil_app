import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_diary/src/components/achievement_widgets/initialize_achievements.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize achievements in Firestore
  Future<void> initializeAchievements() async {
    try {
      final collectionRef = _firestore.collection('achievements');
      final querySnapshot = await collectionRef.get();

      // Collect existing achievement IDs from Firestore
      final existingAchievementIds =
          querySnapshot.docs.map((doc) => doc.id).toSet();

      // Filter out achievements that do not exist in Firestore
      final achievementsToAdd = achievements.where((achievement) {
        return !existingAchievementIds.contains(achievement.id);
      }).toList();

      // Add missing achievements to Firestore
      for (final achievement in achievementsToAdd) {
        await collectionRef.doc(achievement.id).set(achievement.toMap());
      }

      if (kDebugMode) {
        print('Achievements initialized successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing achievements: $e');
      }
    }
  }
}
