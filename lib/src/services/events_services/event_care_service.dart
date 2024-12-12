import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';

class EventCareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // StreamController to manage cache and broadcasting stream data for real-time updates
  final StreamController<List<EventCareModel>> _caresController =
      StreamController<List<EventCareModel>>.broadcast();

  // Cache for fetched event cares to optimize performance
  List<EventCareModel> _cachedCares = [];

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  // Cache duration
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Timestamp for the last cache update
  DateTime? _lastCacheUpdate;

  /// Stream to get real-time updates of user's care events.
  Stream<List<EventCareModel>> getCaresStream() {
    if (_isCacheValid()) {
      // Return cached data if valid
      return Stream.value(_cachedCares);
    }

    try {
      final subscription =
          _firestore.collection('event_cares').snapshots().listen(
        (snapshot) {
          _cachedCares = snapshot.docs
              .map((doc) => EventCareModel.fromDocument(doc))
              .toList();
          _lastCacheUpdate = DateTime.now();

          if (_cachedCares.isNotEmpty) {
            _caresController.add(_cachedCares);
          }
        },
        onError: (error) {
          debugPrint('Error listening to event_cares snapshots: $error');
          _caresController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _caresController.stream;
    } catch (e) {
      debugPrint('Error in getCaresStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new care event to Firestore.
  Future<void> addCare(EventCareModel care) async {
    try {
      await _firestore.collection('event_cares').doc(care.id).set(care.toMap());

      // Update cache and stream
      _cachedCares.add(care);
      _caresController.add(_cachedCares);
    } catch (e) {
      debugPrint('Error adding care event: $e');
    }
  }

  /// Deletes a care event from Firestore.
  Future<void> deleteCare(String careId) async {
    try {
      await _firestore.collection('event_cares').doc(careId).delete();

      // Update cache and stream
      _cachedCares.removeWhere((care) => care.id == careId);
      _caresController.add(_cachedCares);
    } catch (e) {
      debugPrint('Error deleting care event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _caresController.close();
  }

  /// Helper method to check if the cache is still valid
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration;
  }
}
