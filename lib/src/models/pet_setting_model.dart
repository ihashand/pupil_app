import 'package:cloud_firestore/cloud_firestore.dart';

class PetSettingsModel {
  String id;
  String petId;
  int dailyKcal;
  double proteinPercentage;
  double fatPercentage;
  double carbsPercentage;
  List<String> mealTypes;

  PetSettingsModel({
    required this.id,
    required this.petId,
    required this.dailyKcal,
    required this.proteinPercentage,
    required this.fatPercentage,
    required this.carbsPercentage,
    required this.mealTypes,
  });

  factory PetSettingsModel.fromDocument(DocumentSnapshot doc) {
    return PetSettingsModel(
      id: doc.id,
      petId: doc.get('petId'),
      dailyKcal: doc.get('dailyKcal'),
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

  PetSettingsModel copyWith({
    String? id,
    String? petId,
    int? dailyKcal,
    double? proteinPercentage,
    double? fatPercentage,
    double? carbsPercentage,
    List<String>? mealTypes,
  }) {
    return PetSettingsModel(
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
