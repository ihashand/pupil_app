import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_eaten_meal_model.dart';

final eventFoodEatenMealServiceProvider =
    Provider<EventFoodEatenMealService>((ref) {
  return EventFoodEatenMealService();
});

final eventFoodEatenMealsProvider =
    StreamProvider<List<EventEatenMealModel>>((ref) {
  return ref.read(eventFoodEatenMealServiceProvider).getEatenMealsStream();
});

class EventFoodEatenMealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for fetched meals
  List<EventEatenMealModel> _cachedMeals = [];

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  // Cache duration
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Timestamp for the last cache update
  DateTime? _lastCacheUpdate;

  // StreamController for broadcasting cached meals
  final StreamController<List<EventEatenMealModel>> _mealsController =
      StreamController<List<EventEatenMealModel>>.broadcast();

  /// Stream to get real-time updates of eaten meals.
  Stream<List<EventEatenMealModel>> getEatenMealsStream() {
    if (_isCacheValid()) {
      // Return cached data if valid
      return Stream.value(_cachedMeals);
    }

    try {
      final subscription = _firestore
          .collection('event_food_eaten_meals')
          .snapshots()
          .listen((snapshot) {
        _cachedMeals = snapshot.docs
            .map((doc) => EventEatenMealModel.fromDocument(doc))
            .toList();
        _lastCacheUpdate = DateTime.now();

        if (_cachedMeals.isNotEmpty) {
          _mealsController.add(_cachedMeals);
        }
      }, onError: (error) {
        debugPrint(
            'Error listening to event_food_eaten_meals snapshots: $error');
        _mealsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _mealsController.stream;
    } catch (e) {
      debugPrint('Error in getEatenMealsStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new eaten meal to Firestore.
  Future<void> addEatenMeal(String petId, EventEatenMealModel meal) async {
    try {
      await _firestore.collection('event_food_eaten_meals').add(meal.toMap());

      // Update cache and stream
      _cachedMeals.add(meal);
      _mealsController.add(_cachedMeals);
    } catch (e) {
      debugPrint('Error adding eaten meal: $e');
    }
  }

  /// Deletes an eaten meal from Firestore.
  Future<void> deleteEatenMeal(String petId, String mealId) async {
    try {
      await _firestore
          .collection('event_food_eaten_meals')
          .doc(mealId)
          .delete();

      // Update cache and stream
      _cachedMeals.removeWhere((meal) => meal.id == mealId);
      _mealsController.add(_cachedMeals);
    } catch (e) {
      debugPrint('Error deleting eaten meal: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _mealsController.close();
  }

  /// Helper method to check if the cache is still valid
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration;
  }
}
