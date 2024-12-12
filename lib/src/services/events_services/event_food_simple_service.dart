import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_food_simple_model.dart';

class EventFoodSimpleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache for one-time reads
  List<EventFoodSimpleModel>? _cachedFoodEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // StreamController for broadcasting food events stream
  final StreamController<List<EventFoodSimpleModel>> _foodEventsController =
      StreamController<List<EventFoodSimpleModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Fetches food events once and caches the result.
  Future<List<EventFoodSimpleModel>> getFoodEventsOnce(String petId) async {
    if (_cachedFoodEvents != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedFoodEvents!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('food_simple_events')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: _currentUser?.uid)
          .get();

      _cachedFoodEvents = querySnapshot.docs
          .map((doc) => EventFoodSimpleModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedFoodEvents!;
    } catch (e) {
      debugPrint('Error fetching food events once: $e');
      return [];
    }
  }

  /// Stream to get real-time updates of food events.
  Stream<List<EventFoodSimpleModel>> getFoodEventsStream(String petId) {
    try {
      final subscription = _firestore
          .collection('food_simple_events')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: _currentUser?.uid)
          .snapshots()
          .listen((snapshot) {
        final events = snapshot.docs
            .map((doc) => EventFoodSimpleModel.fromDocument(doc))
            .toList();
        _foodEventsController.add(events);
      }, onError: (error) {
        debugPrint('Error listening to food events stream: $error');
        _foodEventsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _foodEventsController.stream;
    } catch (e) {
      debugPrint('Error in getFoodEventsStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new food event.
  Future<void> addFood(EventFoodSimpleModel foodEvent) async {
    try {
      await _firestore
          .collection('food_simple_events')
          .doc(foodEvent.id)
          .set(foodEvent.toMap());
      _cachedFoodEvents = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding food event: $e');
    }
  }

  /// Updates an existing food event.
  Future<void> updateFood(EventFoodSimpleModel foodEvent) async {
    try {
      await _firestore
          .collection('food_simple_events')
          .doc(foodEvent.id)
          .update(foodEvent.toMap());
      _cachedFoodEvents = null; // Invalidate cache after updating
    } catch (e) {
      debugPrint('Error updating food event: $e');
    }
  }

  /// Deletes a food event by ID.
  Future<void> deleteFood(String id) async {
    try {
      await _firestore.collection('food_simple_events').doc(id).delete();
      _cachedFoodEvents = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting food event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _foodEventsController.close();
  }
}
