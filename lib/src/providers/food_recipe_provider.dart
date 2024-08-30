import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/food_recipe_model.dart';
import 'package:pet_diary/src/providers/product_provider.dart';
import 'package:pet_diary/src/services/food_recipe_service.dart';

final foodRecipeServiceProvider = Provider<FoodRecipeService>((ref) {
  return FoodRecipeService();
});

final globalRecipesProvider = StreamProvider<List<FoodRecipeModel>>((ref) {
  return ref.read(foodRecipeServiceProvider).getGlobalRecipesStream();
});

final userRecipesProvider = StreamProvider<List<FoodRecipeModel>>((ref) {
  return ref.read(foodRecipeServiceProvider).getUserRecipesStream();
});

final userFavoriteRecipesProvider =
    StreamProvider<List<FoodRecipeModel>>((ref) {
  return ref.read(foodRecipeServiceProvider).getUserFavoriteRecipesStream();
});

class FavoriteRecipesNotifier extends StateNotifier<List<FoodRecipeModel>> {
  final FoodRecipeService _recipeService;
  final Ref ref;

  FavoriteRecipesNotifier(this._recipeService, this.ref) : super([]) {
    _loadFavoriteRecipes();
  }

  Future<void> _loadFavoriteRecipes() async {
    final favoriteRecipes =
        await _recipeService.getUserFavoriteRecipesStream().first;
    state = favoriteRecipes;
  }

  Future<void> toggleFavorite(FoodRecipeModel recipe) async {
    if (isFavorite(recipe)) {
      await _recipeService.removeFavoriteRecipe(recipe.id);
      state = state.where((r) => r.id != recipe.id).toList();
    } else {
      await _recipeService.addFavoriteRecipe(recipe);
      state = [...state, recipe];
    }
    ref.refresh(userFavoriteRecipesProvider);
    ref.refresh(combinedFavoritesProvider);
  }

  bool isFavorite(FoodRecipeModel recipe) {
    return state.any((r) => r.id == recipe.id);
  }
}

final favoriteRecipesNotifierProvider =
    StateNotifierProvider<FavoriteRecipesNotifier, List<FoodRecipeModel>>(
        (ref) {
  final recipeService = ref.read(foodRecipeServiceProvider);
  return FavoriteRecipesNotifier(recipeService, ref);
});

final combinedMyOwnProvider = StreamProvider<List<dynamic>>((ref) async* {
  final productsStream = ref.watch(userProductsProvider.stream);
  final recipesStream = ref.watch(userRecipesProvider.stream);

  await for (final products in productsStream) {
    final recipes = await recipesStream.first;
    yield [...products, ...recipes];
  }
});

final combinedAllProvider = StreamProvider<List<dynamic>>((ref) async* {
  final productsStream = ref.watch(globalProductsProvider.stream);
  final recipesStream = ref.watch(globalRecipesProvider.stream);

  await for (final products in productsStream) {
    final recipes = await recipesStream.first;
    yield [...products, ...recipes];
  }
});

final combinedFavoritesProvider = StreamProvider<List<dynamic>>((ref) async* {
  final favoriteProductsStream = ref.watch(userFavoriteProductsProvider.stream);
  final favoriteRecipesStream = ref.watch(userFavoriteRecipesProvider.stream);

  await for (final favoriteProducts in favoriteProductsStream) {
    final favoriteRecipes = await favoriteRecipesStream.first;
    yield [...favoriteProducts, ...favoriteRecipes];
  }
});
