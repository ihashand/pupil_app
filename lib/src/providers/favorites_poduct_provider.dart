import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/services/favorties_product_service.dart';

final favoriteProductServiceProvider =
    Provider<FavoritesProductsService>((ref) {
  return FavoritesProductsService();
});

final favoriteProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(favoriteProductServiceProvider).getFavoriteProductsStream();
});
