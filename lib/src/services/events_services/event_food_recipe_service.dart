import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_food_recipe_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';

class EventFoodRecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamControllers for broadcasting recipe streams
  final StreamController<List<EventFoodRecipeModel>> _globalRecipesController =
      StreamController<List<EventFoodRecipeModel>>.broadcast();
  final StreamController<List<EventFoodRecipeModel>> _userRecipesController =
      StreamController<List<EventFoodRecipeModel>>.broadcast();
  final StreamController<List<EventFoodRecipeModel>>
      _favoriteRecipesController =
      StreamController<List<EventFoodRecipeModel>>.broadcast();

  // Cache for fetched recipes
  List<EventFoodRecipeModel> _cachedGlobalRecipes = [];
  List<EventFoodRecipeModel> _cachedUserRecipes = [];
  List<EventFoodRecipeModel> _cachedFavoriteRecipes = [];

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  // Cache duration
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Timestamp for the last cache update
  DateTime? _lastGlobalCacheUpdate;
  DateTime? _lastUserCacheUpdate;
  DateTime? _lastFavoritesCacheUpdate;

  /// Adds a food recipe to Firestore.
  Future<void> addFoodRecipe(EventFoodRecipeModel recipe, String petId,
      {bool isGlobal = true}) async {
    try {
      if (isGlobal) {
        await _firestore.collection('global_recipes').add(recipe.toMap());
      } else {
        if (_currentUser != null) {
          await _firestore
              .collection('event_food_user_recipes')
              .add(recipe.toMap());
        }
      }
      _refreshProviders();
    } catch (e) {
      debugPrint('Error adding food recipe: $e');
    }
  }

  /// Stream to get global recipes.
  Stream<List<EventFoodRecipeModel>> getGlobalRecipesStream() {
    if (_isCacheValid(_lastGlobalCacheUpdate)) {
      return Stream.value(_cachedGlobalRecipes);
    }

    try {
      final subscription =
          _firestore.collection('global_recipes').snapshots().listen(
        (snapshot) {
          _cachedGlobalRecipes = snapshot.docs
              .map((doc) => EventFoodRecipeModel.fromMap(doc.data()))
              .toList();
          _lastGlobalCacheUpdate = DateTime.now();

          _globalRecipesController.add(_cachedGlobalRecipes);
        },
        onError: (error) {
          debugPrint('Error fetching global recipes: $error');
          _globalRecipesController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _globalRecipesController.stream;
    } catch (e) {
      debugPrint('Error in getGlobalRecipesStream: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get user-specific recipes.
  Stream<List<EventFoodRecipeModel>> getUserRecipesStream() {
    if (_isCacheValid(_lastUserCacheUpdate)) {
      return Stream.value(_cachedUserRecipes);
    }

    try {
      final subscription = _firestore
          .collection('event_food_user_recipes')
          .snapshots()
          .listen((snapshot) {
        _cachedUserRecipes = snapshot.docs
            .map((doc) => EventFoodRecipeModel.fromMap(doc.data()))
            .toList();
        _lastUserCacheUpdate = DateTime.now();

        _userRecipesController.add(_cachedUserRecipes);
      }, onError: (error) {
        debugPrint('Error fetching user recipes: $error');
        _userRecipesController.addError(error);
      });

      _subscriptions.add(subscription);
      return _userRecipesController.stream;
    } catch (e) {
      debugPrint('Error in getUserRecipesStream: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get user favorite recipes.
  Stream<List<EventFoodRecipeModel>> getUserFavoriteRecipesStream() {
    if (_isCacheValid(_lastFavoritesCacheUpdate)) {
      return Stream.value(_cachedFavoriteRecipes);
    }

    try {
      final subscription = _firestore
          .collection('event_food_favorites_recipes')
          .snapshots()
          .listen((snapshot) {
        _cachedFavoriteRecipes = snapshot.docs
            .map((doc) => EventFoodRecipeModel.fromMap(doc.data()))
            .toList();
        _lastFavoritesCacheUpdate = DateTime.now();

        _favoriteRecipesController.add(_cachedFavoriteRecipes);
      }, onError: (error) {
        debugPrint('Error fetching favorite recipes: $error');
        _favoriteRecipesController.addError(error);
      });

      _subscriptions.add(subscription);
      return _favoriteRecipesController.stream;
    } catch (e) {
      debugPrint('Error in getUserFavoriteRecipesStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a recipe to favorites.
  Future<void> addFavoriteRecipe(EventFoodRecipeModel recipe) async {
    try {
      await _firestore
          .collection('event_food_favorites_recipes')
          .doc(recipe.id)
          .set(recipe.toMap());
    } catch (e) {
      debugPrint('Error adding favorite recipe: $e');
    }
  }

  /// Removes a recipe from favorites.
  Future<void> removeFavoriteRecipe(String recipeId) async {
    try {
      await _firestore
          .collection('event_food_favorites_recipes')
          .doc(recipeId)
          .delete();
    } catch (e) {
      debugPrint('Error removing favorite recipe: $e');
    }
  }

  /// Removes a recipe from all collections.
  Future<void> removeRecipeFromAll(String recipeId) async {
    try {
      final globalRecipeDoc =
          await _firestore.collection('global_recipes').doc(recipeId).get();
      if (globalRecipeDoc.exists) {
        await globalRecipeDoc.reference.delete();
      }

      final userRecipeDoc = await _firestore
          .collection('event_food_user_recipes')
          .doc(recipeId)
          .get();
      if (userRecipeDoc.exists) {
        await userRecipeDoc.reference.delete();
      }

      final favoriteRecipeDoc = await _firestore
          .collection('event_food_favorites_recipes')
          .doc(recipeId)
          .get();
      if (favoriteRecipeDoc.exists) {
        await favoriteRecipeDoc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error removing recipe from all collections: $e');
    }
  }

  /// Refresh providers to update UI.
  void _refreshProviders() {
    try {
      final container = ProviderContainer();
      container.refresh(eventGlobalRecipesProvider);
      container.refresh(eventUserRecipesProvider);
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
    _globalRecipesController.close();
    _userRecipesController.close();
    _favoriteRecipesController.close();
  }

  /// Helper method to check if the cache is still valid
  bool _isCacheValid(DateTime? lastUpdate) {
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate) < _cacheDuration;
  }
}
