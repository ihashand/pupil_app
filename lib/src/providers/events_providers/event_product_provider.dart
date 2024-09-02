import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';
import 'package:pet_diary/src/services/product_service.dart';

final eventProductServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final eventGlobalProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(eventProductServiceProvider).getProductsStream();
});

final eventUserProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(eventProductServiceProvider).getUserProductsStream();
});

final eventUserFavoriteProductsProvider =
    StreamProvider<List<ProductModel>>((ref) {
  return ref.read(eventProductServiceProvider).getUserFavoriteProductsStream();
});

class EventFavoriteProductsNotifier extends StateNotifier<List<ProductModel>> {
  final ProductService _productService;
  final Ref ref;

  EventFavoriteProductsNotifier(this._productService, this.ref) : super([]) {
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    final favoriteProducts =
        await _productService.getUserFavoriteProductsStream().first;
    state = favoriteProducts;
  }

  Future<void> toggleFavorite(ProductModel product) async {
    if (isFavorite(product)) {
      await _productService.removeFavoriteProduct(product.id);
      state = state.where((p) => p.id != product.id).toList();
    } else {
      await _productService.addFavoriteProduct(product);
      state = [...state, product];
    }
    ref.refresh(
        eventUserFavoriteProductsProvider); // Odświeżenie ulubionych produktów
    ref.refresh(combinedFavoritesProvider); // Odświeżenie łączonych ulubionych
  }

  bool isFavorite(ProductModel product) {
    return state.any((p) => p.id == product.id);
  }
}

final eventFavoriteProductsNotifierProvider =
    StateNotifierProvider<EventFavoriteProductsNotifier, List<ProductModel>>(
        (ref) {
  final productService = ref.read(eventProductServiceProvider);
  return EventFavoriteProductsNotifier(productService, ref);
});
