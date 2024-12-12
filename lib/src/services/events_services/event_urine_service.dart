import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';

class EventUrineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting urine events stream
  final StreamController<List<EventUrineModel>> _urineEventsController =
      StreamController<List<EventUrineModel>>.broadcast();

  // Cache for fetched urine events
  List<EventUrineModel>? _cachedUrineEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of urine events for a specific petId.
  Stream<List<EventUrineModel>> getUrineEventsStream(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedUrineEvents != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _urineEventsController.add(_cachedUrineEvents!);
      } else {
        final subscription = _firestore
            .collection('event_urines')
            .where('petId', isEqualTo: petId)
            .where('userId', isEqualTo: _currentUser.uid)
            .snapshots()
            .listen((snapshot) {
          final urineEvents = snapshot.docs
              .map((doc) => EventUrineModel.fromDocument(doc))
              .toList();
          _cachedUrineEvents = urineEvents;
          _lastFetchTime = DateTime.now();
          _urineEventsController.add(urineEvents);
        }, onError: (error) {
          debugPrint('Error listening to urine events stream: $error');
          _urineEventsController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _urineEventsController.stream;
    } catch (e) {
      debugPrint('Error in getUrineEventsStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new urine event to Firestore.
  Future<void> addUrineEvent(EventUrineModel event) async {
    try {
      await _firestore
          .collection('event_urines')
          .doc(event.id)
          .set(event.toMap());
      _cachedUrineEvents = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding urine event: $e');
    }
  }

  /// Deletes a urine event from Firestore by ID.
  Future<void> deleteUrineEvent(String eventId) async {
    try {
      await _firestore.collection('event_urines').doc(eventId).delete();
      _cachedUrineEvents?.removeWhere((event) => event.id == eventId);
      _urineEventsController
          .add(_cachedUrineEvents!); // Update stream after deletion
    } catch (e) {
      debugPrint('Error deleting urine event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _urineEventsController.close();
  }
}
