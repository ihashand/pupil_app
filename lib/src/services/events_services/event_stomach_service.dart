import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_stomach_model.dart';

class EventStomachService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting stomach events stream
  final StreamController<List<EventStomachModel>> _stomachController =
      StreamController<List<EventStomachModel>>.broadcast();

  // Cache for fetched stomach events
  List<EventStomachModel>? _cachedStomachs;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of stomach events.
  Stream<List<EventStomachModel>> getStomachStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedStomachs != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _stomachController.add(_cachedStomachs!);
      } else {
        final subscription = _firestore
            .collection('event_stomachs')
            .snapshots()
            .listen((snapshot) {
          final stomachs = snapshot.docs
              .map((doc) => EventStomachModel.fromDocument(doc))
              .toList();
          _cachedStomachs = stomachs;
          _lastFetchTime = DateTime.now();
          _stomachController.add(stomachs);
        }, onError: (error) {
          debugPrint('Error listening to stomach stream: $error');
          _stomachController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _stomachController.stream;
    } catch (e) {
      debugPrint('Error in getStomachStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new stomach event.
  Future<void> addStomach(EventStomachModel event) async {
    try {
      await _firestore
          .collection('event_stomachs')
          .doc(event.id)
          .set(event.toMap());
      _cachedStomachs = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding stomach event: $e');
    }
  }

  /// Deletes a stomach event by ID.
  Future<void> deleteStomach(String eventId) async {
    try {
      await _firestore.collection('event_stomachs').doc(eventId).delete();
      _cachedStomachs?.removeWhere((event) => event.id == eventId);
      _stomachController.add(_cachedStomachs!); // Update stream after deletion
    } catch (e) {
      debugPrint('Error deleting stomach event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _stomachController.close();
  }
}
