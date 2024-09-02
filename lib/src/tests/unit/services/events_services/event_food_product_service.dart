import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/product_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';

class EventFoodProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream Controllers
  final StreamController<List<ProductModel>> _globalProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<List<ProductModel>> _userProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<List<ProductModel>> _userFavoritesController =
      StreamController<List<ProductModel>>.broadcast();

  // Getters for Streams
  Stream<List<ProductModel>> getProductsStream() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _globalProductsController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });

    return _globalProductsController.stream;
  }

  Stream<List<ProductModel>> getUserProductsStream() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _firestore
        .collection('app_users')
        .doc(userId)
        .collection('event_food_user_products')
        .snapshots()
        .listen((snapshot) {
      _userProductsController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });

    return _userProductsController.stream;
  }

  Stream<List<ProductModel>> getUserFavoriteProductsStream() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _firestore
        .collection('app_users')
        .doc(userId)
        .collection('event_food_favorites')
        .snapshots()
        .listen((snapshot) {
      _userFavoritesController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });

    return _userFavoritesController.stream;
  }

  // Product Operations
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
    } else {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('app_users')
            .doc(userId)
            .collection('event_food_user_products')
            .add(product.toMap());
      }
    }
    // Refresh relevant providers
    final container = ProviderContainer();
    container.refresh(eventGlobalProductsProvider);
    container.refresh(eventUserProductsProvider);
    container.refresh(combinedAllProvider);
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

  // Favorite Operations
  Future<void> addFavoriteProduct(ProductModel product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('app_users')
          .doc(userId)
          .collection('event_food_favorites')
          .doc(product.id)
          .set(product.toMap());
    }
  }

  Future<void> removeFavoriteProduct(String productId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('app_users')
          .doc(userId)
          .collection('event_food_favorites')
          .doc(productId)
          .delete();
    }
  }

  // New method to remove a product from all locations
  Future<void> removeProductFromAll(String productId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Remove from favorites if it exists
      final favoriteDoc = await _firestore
          .collection('app_users')
          .doc(userId)
          .collection('event_food_favorites')
          .doc(productId)
          .get();
      if (favoriteDoc.exists) {
        await favoriteDoc.reference.delete();
      }

      // Remove from user products if it exists
      final userProductDoc = await _firestore
          .collection('app_users')
          .doc(userId)
          .collection('event_food_user_products')
          .doc(productId)
          .get();
      if (userProductDoc.exists) {
        await userProductDoc.reference.delete();
      }

      // Remove from global products if it exists
      final globalProductDoc =
          await _firestore.collection('products').doc(productId).get();
      if (globalProductDoc.exists) {
        await globalProductDoc.reference.delete();
      }
    }
  }

  // Dispose Stream Controllers
  void dispose() {
    _globalProductsController.close();
    _userProductsController.close();
    _userFavoritesController.close();
  }
}
