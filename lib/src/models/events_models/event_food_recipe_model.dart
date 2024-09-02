class EventFoodRecipeModel {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> preparationSteps;
  final int? preparationTime;
  final double totalKcal;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;
  bool isFavorite;

  EventFoodRecipeModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.preparationSteps,
    this.preparationTime,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
    this.isFavorite = false,
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
      'isFavorite': isFavorite,
    };
  }

  static EventFoodRecipeModel fromMap(Map<String, dynamic> map) {
    return EventFoodRecipeModel(
      id: map['id'],
      name: map['name'],
      ingredients: List<String>.from(map['ingredients']),
      preparationSteps: List<String>.from(map['preparationSteps']),
      preparationTime: map['preparationTime'],
      totalKcal: map['totalKcal'],
      totalProtein: map['totalProtein'],
      totalFat: map['totalFat'],
      totalCarbs: map['totalCarbs'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
