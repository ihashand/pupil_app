import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_food_recipe_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';
import 'package:pet_diary/src/services/event_food_recipe_service.dart';

final eventFoodRecipeServiceProvider = Provider<EventFoodRecipeService>((ref) {
  return EventFoodRecipeService();
});

final eventGlobalRecipesProvider =
    StreamProvider<List<EventFoodRecipeModel>>((ref) {
  return ref.read(eventFoodRecipeServiceProvider).getGlobalRecipesStream();
});

final eventUserRecipesProvider =
    StreamProvider<List<EventFoodRecipeModel>>((ref) {
  return ref.read(eventFoodRecipeServiceProvider).getUserRecipesStream();
});

final eventUserFavoriteRecipesProvider =
    StreamProvider<List<EventFoodRecipeModel>>((ref) {
  return ref
      .read(eventFoodRecipeServiceProvider)
      .getUserFavoriteRecipesStream();
});

class EventFavoriteRecipesNotifier
    extends StateNotifier<List<EventFoodRecipeModel>> {
  final EventFoodRecipeService _recipeService;
  final Ref ref;

  EventFavoriteRecipesNotifier(this._recipeService, this.ref) : super([]) {
    _loadFavoriteRecipes();
  }

  Future<void> _loadFavoriteRecipes() async {
    final favoriteRecipes =
        await _recipeService.getUserFavoriteRecipesStream().first;
    state = favoriteRecipes;
  }

  Future<void> toggleFavorite(EventFoodRecipeModel recipe) async {
    if (isFavorite(recipe)) {
      await _recipeService.removeFavoriteRecipe(recipe.id);
      state = state.where((r) => r.id != recipe.id).toList();
    } else {
      await _recipeService.addFavoriteRecipe(recipe);
      state = [...state, recipe];
    }
    ref.refresh(eventUserFavoriteRecipesProvider);
    ref.refresh(combinedFavoritesProvider);
  }

  bool isFavorite(EventFoodRecipeModel recipe) {
    return state.any((r) => r.id == recipe.id);
  }
}

final favoriteRecipesNotifierProvider = StateNotifierProvider<
    EventFavoriteRecipesNotifier, List<EventFoodRecipeModel>>((ref) {
  final recipeService = ref.read(eventFoodRecipeServiceProvider);
  return EventFavoriteRecipesNotifier(recipeService, ref);
});

final combinedMyOwnProvider = StreamProvider<List<dynamic>>((ref) async* {
  final productsStream = ref.watch(eventUserProductsProvider.stream);
  final recipesStream = ref.watch(eventUserRecipesProvider.stream);

  await for (final products in productsStream) {
    final recipes = await recipesStream.first;
    yield [...products, ...recipes];
  }
});

final combinedAllProvider = StreamProvider<List<dynamic>>((ref) async* {
  final productsStream = ref.watch(eventGlobalProductsProvider.stream);
  final recipesStream = ref.watch(eventGlobalRecipesProvider.stream);

  await for (final products in productsStream) {
    final recipes = await recipesStream.first;
    yield [...products, ...recipes];
  }
});

final combinedFavoritesProvider = StreamProvider<List<dynamic>>((ref) async* {
  final favoriteProductsStream =
      ref.watch(eventUserFavoriteProductsProvider.stream);
  final favoriteRecipesStream =
      ref.watch(eventUserFavoriteRecipesProvider.stream);

  await for (final favoriteProducts in favoriteProductsStream) {
    final favoriteRecipes = await favoriteRecipesStream.first;
    yield [...favoriteProducts, ...favoriteRecipes];
  }
});
