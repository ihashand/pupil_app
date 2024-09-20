import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_diary/src/components/achievement_widgets/initialize_achievements.dart';
import 'package:pet_diary/src/models/others/achievement.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Achievement> getSeasonalAchievement() async {
    try {
      final DateTime now = DateTime.now();
      final String seasonalId =
          'seasonal_${now.year}_${now.month.toString().padLeft(2, '0')}';

      // Debugging log
      if (kDebugMode) {
        print('Fetching achievement with ID: $seasonalId');
      }

      final doc =
          await _firestore.collection('achievements').doc(seasonalId).get();
      if (doc.exists) {
        return Achievement.fromDocument(doc);
      } else {
        throw Exception('No seasonal achievement found for ID: $seasonalId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching seasonal achievement: $e');
      }
      throw Exception('Failed to load seasonal achievement. Error: $e');
    }
  }

  // Inicjalizacja achievementów, jeśli nie istnieją w Firestore
  Future<void> initializeAchievements() async {
    try {
      final collectionRef = _firestore.collection('achievements');
      final querySnapshot = await collectionRef.get();

      final existingAchievementIds =
          querySnapshot.docs.map((doc) => doc.id).toSet();

      final achievementsToAdd = achievements.where((achievement) {
        return !existingAchievementIds.contains(achievement.id);
      }).toList();

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
