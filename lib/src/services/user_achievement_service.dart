import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/user_achievement.dart';

class UserAchievementService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<List<UserAchievement>> getUserAchievements() async {
    final snapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('user_achievements')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();
    return snapshot.docs
        .map((doc) => UserAchievement.fromDocument(doc))
        .toList();
  }

  Future<void> addUserAchievement(UserAchievement userAchievement) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('user_achievements')
        .doc(userAchievement.id)
        .set(userAchievement.toMap());
  }

  Future<void> updateUserAchievement(UserAchievement userAchievement) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('user_achievements')
        .doc(userAchievement.id)
        .update(userAchievement.toMap());
  }

  Future<void> deleteUserAchievement(String userAchievementId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('user_achievements')
        .doc(userAchievementId)
        .delete();
  }
}
