import 'package:cloud_firestore/cloud_firestore.dart';

class PetAchievement {
  final String id;
  final String userId;
  final String petId;
  final String achievementId;
  final DateTime achievedAt;

  PetAchievement({
    required this.id,
    required this.userId,
    required this.petId,
    required this.achievementId,
    required this.achievedAt,
  });

  PetAchievement.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        userId = doc.get('userId') ?? '',
        petId = doc.get('petId') ?? '',
        achievementId = doc.get('achievementId') ?? '',
        achievedAt = (doc.get('achievedAt') as Timestamp).toDate();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'petId': petId,
      'achievementId': achievementId,
      'achievedAt': achievedAt,
    };
  }
}
