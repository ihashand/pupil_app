import 'package:cloud_firestore/cloud_firestore.dart';

class EatenMealModel {
  final String id;
  final String name;
  final String? brand;
  final DateTime date;
  final String mealType;
  final double kcal;
  final double? fat;
  final double? carbs;
  final double? protein;
  final double grams;

  EatenMealModel({
    required this.id,
    required this.name,
    this.brand,
    required this.date,
    required this.mealType,
    required this.kcal,
    this.fat,
    this.carbs,
    this.protein,
    required this.grams,
  });

  EatenMealModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        name = doc['name'],
        brand = doc['brand'],
        date = (doc['date'] as Timestamp).toDate(),
        mealType = doc['mealType'],
        kcal = doc['kcal'],
        fat = doc['fat'],
        carbs = doc['carbs'],
        protein = doc['protein'],
        grams = doc['grams'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'date': date,
      'mealType': mealType,
      'kcal': kcal,
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
      'grams': grams,
    };
  }
}
