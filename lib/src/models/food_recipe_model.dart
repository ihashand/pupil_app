class FoodRecipeModel {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> preparationSteps;
  final int? preparationTime;

  FoodRecipeModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.preparationSteps,
    this.preparationTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'preparationSteps': preparationSteps,
      'preparationTime': preparationTime,
    };
  }

  static FoodRecipeModel fromMap(Map<String, dynamic> map) {
    return FoodRecipeModel(
      id: map['id'],
      name: map['name'],
      ingredients: List<String>.from(map['ingredients']),
      preparationSteps: List<String>.from(map['preparationSteps']),
      preparationTime: map['preparationTime'],
    );
  }
}
