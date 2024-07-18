import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/achievement.dart';

class AchievementService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Achievement>> getAllAchievements() async {
    final snapshot = await _firestore.collection('achievements').get();
    return snapshot.docs.map((doc) => Achievement.fromDocument(doc)).toList();
  }

  Future<void> addAchievement(Achievement achievement) async {
    await _firestore
        .collection('achievements')
        .doc(achievement.id)
        .set(achievement.toMap());
  }

  Future<void> updateAchievement(Achievement achievement) async {
    await _firestore
        .collection('achievements')
        .doc(achievement.id)
        .update(achievement.toMap());
  }

  Future<void> deleteAchievement(String achievementId) async {
    await _firestore.collection('achievements').doc(achievementId).delete();
  }
}
