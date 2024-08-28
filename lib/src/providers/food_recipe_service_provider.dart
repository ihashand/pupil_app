import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/food_recipe_service.dart';

final foodRecipeServiceProvider = Provider<FoodRecipeService>((ref) {
  return FoodRecipeService();
});
