import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/providers/product_provider.dart';
import 'package:pet_diary/src/services/favorties_product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final favoriteProductServiceProvider =
    Provider<FavoritesProductsService>((ref) {
  return FavoritesProductsService();
});

final favoriteProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final productService = ref.watch(productServiceProvider);
  final userId = FirebaseAuth.instance.currentUser!.uid;
  return productService.getFavoriteProductsStream(userId);
});
