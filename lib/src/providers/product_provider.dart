import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/services/product_service.dart';

// Provider for accessing the ProductService
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Definiowanie providerów do pobierania produktów globalnych, użytkownika i ulubionych
final globalProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productServiceProvider).getProductsStream();
});

final userProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productServiceProvider).getUserProductsStream();
});

final favoriteProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  // Załóżmy, że mamy metodę do pobierania ulubionych produktów
  return ref.read(productServiceProvider).getFavoriteProductsStream();
});
