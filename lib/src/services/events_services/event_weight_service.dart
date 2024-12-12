import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventWeightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache for fetched weights
  List<EventWeightModel>? _cachedWeights;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // StreamController for broadcasting weight events stream
  final StreamController<List<EventWeightModel>> _weightEventsController =
      StreamController<List<EventWeightModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Fetches weight events once and caches the result.
  Future<List<EventWeightModel>> getWeightsOnce(String petId) async {
    if (_cachedWeights != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWeights!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('event_weights')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: _currentUser?.uid)
          .get();

      _cachedWeights = querySnapshot.docs
          .map((doc) => EventWeightModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedWeights!;
    } catch (e) {
      debugPrint('Error fetching weight events once: $e');
      return [];
    }
  }

  /// Stream to get real-time updates of weight events for a specific pet.
  Stream<List<EventWeightModel>> getWeightsStream(String petId) {
    try {
      final subscription = _firestore
          .collection('event_weights')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: _currentUser?.uid)
          .snapshots()
          .listen((snapshot) {
        final weightEvents = snapshot.docs
            .map((doc) => EventWeightModel.fromDocument(doc))
            .toList();
        _weightEventsController.add(weightEvents);
      }, onError: (error) {
        debugPrint('Error listening to weight events stream: $error');
        _weightEventsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _weightEventsController.stream;
    } catch (e) {
      debugPrint('Error in getWeightsStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetches the last known weight event for a specific pet.
  Future<EventWeightModel?> getLastKnownWeight(String petId) async {
    try {
      final querySnapshot = await _firestore
          .collection('event_weights')
          .where('petId', isEqualTo: petId)
          .orderBy('dateTime', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return EventWeightModel.fromDocument(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching last known weight: $e');
      return null;
    }
  }

  /// Adds a new weight event to Firestore.
  Future<void> addWeight(EventWeightModel weight) async {
    try {
      await _firestore
          .collection('event_weights')
          .doc(weight.id)
          .set(weight.toMap());
      _cachedWeights = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding weight event: $e');
    }
  }

  /// Updates an existing weight event in Firestore.
  Future<void> updateWeight(EventWeightModel weight) async {
    try {
      await _firestore
          .collection('event_weights')
          .doc(weight.id)
          .update(weight.toMap());
      _cachedWeights = null; // Invalidate cache after updating
    } catch (e) {
      debugPrint('Error updating weight event: $e');
    }
  }

  /// Deletes a weight event from Firestore by ID.
  Future<void> deleteWeight(String weightId) async {
    try {
      await _firestore.collection('event_weights').doc(weightId).delete();
      _cachedWeights = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting weight event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _weightEventsController.close();
  }
}
