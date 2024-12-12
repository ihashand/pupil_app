import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';

class EventStoolService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting stool events stream
  final StreamController<List<EventStoolModel>> _stoolEventsController =
      StreamController<List<EventStoolModel>>.broadcast();

  // Cache for fetched stool events
  List<EventStoolModel>? _cachedStoolEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of stool events.
  Stream<List<EventStoolModel>> getStoolEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedStoolEvents != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _stoolEventsController.add(_cachedStoolEvents!);
      } else {
        final subscription = _firestore
            .collection('event_stools')
            .where('userId', isEqualTo: _currentUser.uid)
            .snapshots()
            .listen((snapshot) {
          final stoolEvents = snapshot.docs
              .map((doc) => EventStoolModel.fromDocument(doc))
              .toList();
          _cachedStoolEvents = stoolEvents;
          _lastFetchTime = DateTime.now();
          _stoolEventsController.add(stoolEvents);
        }, onError: (error) {
          debugPrint('Error listening to stool events stream: $error');
          _stoolEventsController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _stoolEventsController.stream;
    } catch (e) {
      debugPrint('Error in getStoolEventsStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new stool event.
  Future<void> addStoolEvent(EventStoolModel event) async {
    try {
      await _firestore
          .collection('event_stools')
          .doc(event.id)
          .set(event.toMap());
      _cachedStoolEvents = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding stool event: $e');
    }
  }

  /// Deletes a stool event by ID.
  Future<void> deleteStoolEvent(String eventId) async {
    try {
      await _firestore.collection('event_stools').doc(eventId).delete();
      _cachedStoolEvents?.removeWhere((event) => event.id == eventId);
      _stoolEventsController
          .add(_cachedStoolEvents!); // Update stream after deletion
    } catch (e) {
      debugPrint('Error deleting stool event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _stoolEventsController.close();
  }
}
