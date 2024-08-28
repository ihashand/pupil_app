import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final globalProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productServiceProvider).getProductsStream();
});

final userProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productServiceProvider).getUserProductsStream();
});

final userFavoriteProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productServiceProvider).getUserFavoriteProductsStream();
});

class FavoriteProductsNotifier extends StateNotifier<List<ProductModel>> {
  final ProductService _productService;

  FavoriteProductsNotifier(this._productService) : super([]) {
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
  }

  bool isFavorite(ProductModel product) {
    return state.any((p) => p.id == product.id);
  }
}

final favoriteProductsNotifierProvider =
    StateNotifierProvider<FavoriteProductsNotifier, List<ProductModel>>((ref) {
  final productService = ref.read(productServiceProvider);
  return FavoriteProductsNotifier(productService);
});
