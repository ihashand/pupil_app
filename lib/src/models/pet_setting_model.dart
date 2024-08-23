import 'package:cloud_firestore/cloud_firestore.dart';

class PetSettingsModel {
  String id;
  String petId;
  int dailyKcal;
  List<String> mealTypes;

  PetSettingsModel({
    required this.id,
    required this.petId,
    required this.dailyKcal,
    required this.mealTypes,
  });

  factory PetSettingsModel.fromDocument(DocumentSnapshot doc) {
    return PetSettingsModel(
      id: doc.id,
      petId: doc.get('petId'),
      dailyKcal: doc.get('dailyKcal'),
      mealTypes: List<String>.from(doc.get('mealTypes')),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'dailyKcal': dailyKcal,
      'mealTypes': mealTypes,
    };
  }
}
