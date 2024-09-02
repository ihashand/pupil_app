import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? brand;
  final String? barcode;
  final double kcal;
  final double? fat;
  final double? carbs;
  final double? protein;

  ProductModel({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.kcal,
    this.fat,
    this.carbs,
    this.protein,
  });

  ProductModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        name = doc['name'],
        brand = doc['brand'],
        barcode = doc['barcode'],
        kcal = doc['kcal'],
        fat = doc['fat'],
        carbs = doc['carbs'],
        protein = doc['protein'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'barcode': barcode,
      'kcal': kcal,
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
    };
  }
}
