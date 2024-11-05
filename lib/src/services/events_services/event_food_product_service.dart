import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';

class EventFoodProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  final StreamController<List<ProductModel>> _globalProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<List<ProductModel>> _userProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<List<ProductModel>> _userFavoritesController =
      StreamController<List<ProductModel>>.broadcast();

  Stream<List<ProductModel>> getProductsStream() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _globalProductsController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });
    return _globalProductsController.stream;
  }

  Stream<List<ProductModel>> getUserProductsStream() {
    _firestore
        .collection('event_food_user_products')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _userProductsController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });
    return _userProductsController.stream;
  }

  Stream<List<ProductModel>> getUserFavoriteProductsStream() {
    _firestore
        .collection('event_food_favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _userFavoritesController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });
    return _userFavoritesController.stream;
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return ProductModel.fromDocument(querySnapshot.docs.first);
    }
    return null;
  }

  Future<void> addProduct(ProductModel product, {bool isGlobal = true}) async {
    if (isGlobal) {
      await _firestore.collection('products').add(product.toMap());
    } else if (userId != null) {
      await _firestore
          .collection('event_food_user_products')
          .doc()
          .set({...product.toMap(), 'userId': userId});
    }
    _refreshProviders();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Future<void> addFavoriteProduct(ProductModel product) async {
    await _firestore
        .collection('event_food_favorites')
        .doc()
        .set({...product.toMap(), 'userId': userId});
  }

  Future<void> removeFavoriteProduct(String productId) async {
    if (userId != null) {
      final snapshot = await _firestore
          .collection('event_food_favorites')
          .where('userId', isEqualTo: userId)
          .where('id', isEqualTo: productId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    }
  }

  Future<void> removeProductFromAll(String productId) async {
    if (userId != null) {
      await _removeFromCollectionIfExists(
          'event_food_favorites', productId, userId!);
      await _removeFromCollectionIfExists(
          'event_food_user_products', productId, userId!);
      await _removeFromCollectionIfExists('products', productId, userId!);
    }
  }

  Future<void> _removeFromCollectionIfExists(
      String collection, String productId, String userId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .where('id', isEqualTo: productId)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  void _refreshProviders() {
    final container = ProviderContainer();
    container.refresh(eventGlobalProductsProvider);
    container.refresh(eventUserProductsProvider);
    container.refresh(combinedAllProvider);
  }

  void dispose() {
    _globalProductsController.close();
    _userProductsController.close();
    _userFavoritesController.close();
  }
}
