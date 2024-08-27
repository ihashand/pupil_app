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
