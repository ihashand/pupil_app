import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';

class EventWaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache for fetched water events
  List<EventWaterModel>? _cachedWaterEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // StreamController for broadcasting water events stream
  final StreamController<List<EventWaterModel>> _waterEventsController =
      StreamController<List<EventWaterModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Fetches water events once and caches the result.
  Future<List<EventWaterModel>> getWatersOnce(String petId) async {
    if (_cachedWaterEvents != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWaterEvents!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('event_waters')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: _currentUser?.uid)
          .get();

      _cachedWaterEvents = querySnapshot.docs
          .map((doc) => EventWaterModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedWaterEvents!;
    } catch (e) {
      debugPrint('Error fetching water events once: $e');
      return [];
    }
  }

  /// Stream to get real-time updates of water events for a specific pet.
  Stream<List<EventWaterModel>> getWatersStream(String petId) {
    try {
      final subscription = _firestore
          .collection('event_waters')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: _currentUser?.uid)
          .snapshots()
          .listen((snapshot) {
        final waterEvents = snapshot.docs
            .map((doc) => EventWaterModel.fromDocument(doc))
            .toList();
        _waterEventsController.add(waterEvents);
      }, onError: (error) {
        debugPrint('Error listening to water events stream: $error');
        _waterEventsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _waterEventsController.stream;
    } catch (e) {
      debugPrint('Error in getWatersStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetches a specific water event by ID.
  Future<EventWaterModel?> getWaterById(String waterId) async {
    try {
      final docSnapshot =
          await _firestore.collection('event_waters').doc(waterId).get();

      return docSnapshot.exists
          ? EventWaterModel.fromDocument(docSnapshot)
          : null;
    } catch (e) {
      debugPrint('Error fetching water event by ID: $e');
      return null;
    }
  }

  /// Adds a new water event to Firestore.
  Future<void> addWater(EventWaterModel waterEvent) async {
    try {
      await _firestore
          .collection('event_waters')
          .doc(waterEvent.id)
          .set(waterEvent.toMap());
      _cachedWaterEvents = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding water event: $e');
    }
  }

  /// Updates an existing water event in Firestore.
  Future<void> updateWater(EventWaterModel waterEvent) async {
    try {
      await _firestore
          .collection('event_waters')
          .doc(waterEvent.id)
          .update(waterEvent.toMap());
      _cachedWaterEvents = null; // Invalidate cache after updating
    } catch (e) {
      debugPrint('Error updating water event: $e');
    }
  }

  /// Deletes a water event from Firestore by ID.
  Future<void> deleteWater(String waterId) async {
    try {
      await _firestore.collection('event_waters').doc(waterId).delete();
      _cachedWaterEvents = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting water event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _waterEventsController.close();
  }
}
