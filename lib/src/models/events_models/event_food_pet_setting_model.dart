import 'package:cloud_firestore/cloud_firestore.dart';

class EventFoodPetSettingsModel {
  String id;
  String petId;
  double dailyKcal;
  double proteinPercentage;
  double fatPercentage;
  double carbsPercentage;
  List<String> mealTypes;

  EventFoodPetSettingsModel({
    required this.id,
    required this.petId,
    required this.dailyKcal,
    required this.proteinPercentage,
    required this.fatPercentage,
    required this.carbsPercentage,
    required this.mealTypes,
  });

  factory EventFoodPetSettingsModel.fromDocument(DocumentSnapshot doc) {
    return EventFoodPetSettingsModel(
      id: doc.id,
      petId: doc.get('petId'),
      dailyKcal: doc.get('dailyKcal') ?? 0.0,
      proteinPercentage: doc.get('proteinPercentage') ?? 0.0,
      fatPercentage: doc.get('fatPercentage') ?? 0.0,
      carbsPercentage: doc.get('carbsPercentage') ?? 0.0,
      mealTypes: List<String>.from(doc.get('mealTypes')),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'dailyKcal': dailyKcal,
      'proteinPercentage': proteinPercentage,
      'fatPercentage': fatPercentage,
      'carbsPercentage': carbsPercentage,
      'mealTypes': mealTypes,
    };
  }

  EventFoodPetSettingsModel copyWith({
    String? id,
    String? petId,
    double? dailyKcal,
    double? proteinPercentage,
    double? fatPercentage,
    double? carbsPercentage,
    List<String>? mealTypes,
  }) {
    return EventFoodPetSettingsModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      dailyKcal: dailyKcal ?? this.dailyKcal,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      carbsPercentage: carbsPercentage ?? this.carbsPercentage,
      mealTypes: mealTypes ?? this.mealTypes,
    );
  }
}
