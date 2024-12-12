import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/others/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';

class EventFoodProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // StreamControllers for broadcasting product streams
  final StreamController<List<ProductModel>> _globalProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<List<ProductModel>> _userProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<List<ProductModel>> _userFavoritesController =
      StreamController<List<ProductModel>>.broadcast();

  // Cache for fetched products
  List<ProductModel> _cachedGlobalProducts = [];
  List<ProductModel> _cachedUserProducts = [];
  List<ProductModel> _cachedUserFavorites = [];

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  // Cache duration
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Timestamp for the last cache update
  DateTime? _lastGlobalCacheUpdate;
  DateTime? _lastUserCacheUpdate;
  DateTime? _lastFavoritesCacheUpdate;

  /// Stream to get global products.
  Stream<List<ProductModel>> getProductsStream() {
    if (_isCacheValid(_lastGlobalCacheUpdate)) {
      return Stream.value(_cachedGlobalProducts);
    }

    try {
      final subscription = _firestore.collection('products').snapshots().listen(
        (snapshot) {
          _cachedGlobalProducts = snapshot.docs
              .map((doc) => ProductModel.fromDocument(doc))
              .toList();
          _lastGlobalCacheUpdate = DateTime.now();

          _globalProductsController.add(_cachedGlobalProducts);
        },
        onError: (error) {
          debugPrint('Error fetching global products: $error');
          _globalProductsController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _globalProductsController.stream;
    } catch (e) {
      debugPrint('Error in getProductsStream: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get user-specific products.
  Stream<List<ProductModel>> getUserProductsStream() {
    if (_isCacheValid(_lastUserCacheUpdate)) {
      return Stream.value(_cachedUserProducts);
    }

    try {
      final subscription = _firestore
          .collection('event_food_user_products')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        _cachedUserProducts =
            snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList();
        _lastUserCacheUpdate = DateTime.now();

        _userProductsController.add(_cachedUserProducts);
      }, onError: (error) {
        debugPrint('Error fetching user products: $error');
        _userProductsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _userProductsController.stream;
    } catch (e) {
      debugPrint('Error in getUserProductsStream: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get user favorite products.
  Stream<List<ProductModel>> getUserFavoriteProductsStream() {
    if (_isCacheValid(_lastFavoritesCacheUpdate)) {
      return Stream.value(_cachedUserFavorites);
    }

    try {
      final subscription = _firestore
          .collection('event_food_favorites')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        _cachedUserFavorites =
            snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList();
        _lastFavoritesCacheUpdate = DateTime.now();

        _userFavoritesController.add(_cachedUserFavorites);
      }, onError: (error) {
        debugPrint('Error fetching favorite products: $error');
        _userFavoritesController.addError(error);
      });

      _subscriptions.add(subscription);
      return _userFavoritesController.stream;
    } catch (e) {
      debugPrint('Error in getUserFavoriteProductsStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetch a product by barcode.
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductModel.fromDocument(querySnapshot.docs.first);
      }
    } catch (e) {
      debugPrint('Error fetching product by barcode: $e');
    }
    return null;
  }

  /// Add a new product.
  Future<void> addProduct(ProductModel product, {bool isGlobal = true}) async {
    try {
      if (isGlobal) {
        await _firestore.collection('products').add(product.toMap());
      } else if (userId != null) {
        await _firestore
            .collection('event_food_user_products')
            .doc()
            .set({...product.toMap(), 'userId': userId});
      }
      _refreshProviders();
    } catch (e) {
      debugPrint('Error adding product: $e');
    }
  }

  /// Update an existing product.
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      debugPrint('Error updating product: $e');
    }
  }

  /// Delete a product.
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      debugPrint('Error deleting product: $e');
    }
  }

  /// Add a product to favorites.
  Future<void> addFavoriteProduct(ProductModel product) async {
    try {
      if (userId != null) {
        await _firestore
            .collection('event_food_favorites')
            .doc()
            .set({...product.toMap(), 'userId': userId});
      }
    } catch (e) {
      debugPrint('Error adding favorite product: $e');
    }
  }

  /// Remove a product from favorites.
  Future<void> removeFavoriteProduct(String productId) async {
    try {
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
    } catch (e) {
      debugPrint('Error removing favorite product: $e');
    }
  }

  /// Remove a product from all collections.
  Future<void> removeProductFromAll(String productId) async {
    try {
      if (userId != null) {
        await _removeFromCollectionIfExists(
            'event_food_favorites', productId, userId!);
        await _removeFromCollectionIfExists(
            'event_food_user_products', productId, userId!);
        await _removeFromCollectionIfExists('products', productId, userId!);
      }
    } catch (e) {
      debugPrint('Error removing product from all collections: $e');
    }
  }

  Future<void> _removeFromCollectionIfExists(
      String collection, String productId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .where('id', isEqualTo: productId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      debugPrint('Error removing product from $collection: $e');
    }
  }

  /// Refresh providers to update UI.
  void _refreshProviders() {
    try {
      final container = ProviderContainer();
      container.refresh(eventGlobalProductsProvider);
      container.refresh(eventUserProductsProvider);
      container.refresh(combinedAllProvider);
    } catch (e) {
      debugPrint('Error refreshing providers: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _globalProductsController.close();
    _userProductsController.close();
    _userFavoritesController.close();
  }

  /// Helper method to check if the cache is still valid
  bool _isCacheValid(DateTime? lastUpdate) {
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate) < _cacheDuration;
  }
}
