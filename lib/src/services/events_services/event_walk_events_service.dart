import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_walk_events_model.dart';

class EventWalkEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // StreamController for broadcasting walk events stream
  final StreamController<List<EventWalkEventsModel>> _walkEventsController =
      StreamController<List<EventWalkEventsModel>>.broadcast();

  // Cache for fetched walk events
  List<EventWalkEventsModel>? _cachedWalkEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of walk events.
  Stream<List<EventWalkEventsModel>> getEventsWalksEventStream() {
    try {
      if (_cachedWalkEvents != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _walkEventsController.add(_cachedWalkEvents!);
      } else {
        final subscription = _firestore
            .collection('event_walks_events')
            .snapshots()
            .listen((snapshot) {
          final walkEvents = snapshot.docs
              .map((doc) => EventWalkEventsModel.fromDocument(doc))
              .toList();
          _cachedWalkEvents = walkEvents;
          _lastFetchTime = DateTime.now();
          _walkEventsController.add(walkEvents);
        }, onError: (error) {
          debugPrint('Error listening to walk events stream: $error');
          _walkEventsController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _walkEventsController.stream;
    } catch (e) {
      debugPrint('Error in getEventsWalksEventStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new walk event to Firestore.
  Future<void> addEventsWalkEvent(EventWalkEventsModel event) async {
    try {
      await _firestore
          .collection('event_walks_events')
          .doc(event.id)
          .set(event.toMap());
      _cachedWalkEvents = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding walk event: $e');
    }
  }

  /// Deletes a walk event from Firestore by ID.
  Future<void> deleteEventsWalkEvent(String eventId) async {
    try {
      await _firestore.collection('event_walks_events').doc(eventId).delete();
      _cachedWalkEvents?.removeWhere((event) => event.id == eventId);
      _walkEventsController
          .add(_cachedWalkEvents!); // Update stream after deletion
    } catch (e) {
      debugPrint('Error deleting walk event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _walkEventsController.close();
  }
}
