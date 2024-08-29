class FoodRecipeModel {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> preparationSteps;
  final int? preparationTime;
  final double totalKcal;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;

  FoodRecipeModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.preparationSteps,
    this.preparationTime,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'preparationSteps': preparationSteps,
      'preparationTime': preparationTime,
      'totalKcal': totalKcal,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
    };
  }

  static FoodRecipeModel fromMap(Map<String, dynamic> map) {
    return FoodRecipeModel(
      id: map['id'],
      name: map['name'],
      ingredients: List<String>.from(map['ingredients']),
      preparationSteps: List<String>.from(map['preparationSteps']),
      preparationTime: map['preparationTime'],
      totalKcal: map['totalKcal'],
      totalProtein: map['totalProtein'],
      totalFat: map['totalFat'],
      totalCarbs: map['totalCarbs'],
    );
  }
}
