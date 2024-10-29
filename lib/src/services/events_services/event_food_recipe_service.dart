import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_food_recipe_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';

class EventFoodRecipeService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addFoodRecipe(EventFoodRecipeModel recipe, String petId,
      {bool isGlobal = true}) async {
    if (isGlobal) {
      await _firestore.collection('global_recipes').add(recipe.toMap());
    } else {
      if (_currentUser != null) {
        await _firestore
            .collection('event_food_user_recipes')
            .add(recipe.toMap());
      }
    }
    final container = ProviderContainer();
    container.refresh(eventGlobalRecipesProvider);
    container.refresh(eventUserRecipesProvider);
    container.refresh(combinedAllProvider);
  }

  Stream<List<EventFoodRecipeModel>> getGlobalRecipesStream() {
    return _firestore.collection('global_recipes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EventFoodRecipeModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<EventFoodRecipeModel>> getUserRecipesStream() {
    return _firestore
        .collection('event_food_user_recipes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventFoodRecipeModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<EventFoodRecipeModel>> getUserFavoriteRecipesStream() {
    return _firestore
        .collection('event_food_favorites_recipes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventFoodRecipeModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> addFavoriteRecipe(EventFoodRecipeModel recipe) async {
    await _firestore
        .collection('event_food_favorites_recipes')
        .doc(recipe.id)
        .set(recipe.toMap());
  }

  Future<void> removeFavoriteRecipe(String recipeId) async {
    await _firestore
        .collection('event_food_favorites_recipes')
        .doc(recipeId)
        .delete();
  }

  Future<void> removeRecipeFromAll(String recipeId) async {
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
  }
}
