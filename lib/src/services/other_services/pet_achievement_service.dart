import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/others/pet_achievement.dart';

class PetAchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PetAchievement>> getPetAchievements(String petId) async {
    final snapshot = await _firestore.collection('pet_achievements').get();

    return snapshot.docs
        .map((doc) => PetAchievement.fromDocument(doc))
        .toList();
  }

  Future<void> addPetAchievement(PetAchievement petAchievement) async {
    await _firestore
        .collection('pet_achievements')
        .doc(petAchievement.id)
        .set(petAchievement.toMap());
  }

  Future<void> updatePetAchievement(PetAchievement petAchievement) async {
    await _firestore
        .collection('pet_achievements')
        .doc(petAchievement.id)
        .update(petAchievement.toMap());
  }

  Future<void> deletePetAchievement(String achievementId) async {
    await _firestore.collection('pet_achievements').doc(achievementId).delete();
  }
}
