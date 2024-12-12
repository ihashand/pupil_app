import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';

class VaccineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting vaccine events stream
  final StreamController<List<EventVaccineModel>> _vaccineEventsController =
      StreamController<List<EventVaccineModel>>.broadcast();

  // Cache for fetched vaccine events
  List<EventVaccineModel>? _cachedVaccineEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Fetches vaccine events once and caches the result.
  Future<List<EventVaccineModel>> getVaccineEventsOnce() async {
    if (_cachedVaccineEvents != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedVaccineEvents!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('event_vaccines')
          .where('userId', isEqualTo: _currentUser?.uid)
          .get();

      _cachedVaccineEvents = querySnapshot.docs
          .map((doc) => EventVaccineModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedVaccineEvents!;
    } catch (e) {
      debugPrint('Error fetching vaccine events once: $e');
      return [];
    }
  }

  /// Stream to get real-time updates of vaccine events.
  Stream<List<EventVaccineModel>> getVaccineStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      final subscription = _firestore
          .collection('event_vaccines')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        final vaccineEvents = snapshot.docs
            .map((doc) => EventVaccineModel.fromDocument(doc))
            .toList();
        _vaccineEventsController.add(vaccineEvents);
      }, onError: (error) {
        debugPrint('Error listening to vaccine events stream: $error');
        _vaccineEventsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _vaccineEventsController.stream;
    } catch (e) {
      debugPrint('Error in getVaccineStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new vaccine event to Firestore.
  Future<void> addVaccine(EventVaccineModel vaccine) async {
    try {
      await _firestore
          .collection('event_vaccines')
          .doc(vaccine.id)
          .set(vaccine.toMap());
      _cachedVaccineEvents = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding vaccine event: $e');
    }
  }

  /// Deletes a vaccine event from Firestore by ID.
  Future<void> deleteVaccine(String vaccineId) async {
    try {
      await _firestore.collection('event_vaccines').doc(vaccineId).delete();
      _cachedVaccineEvents = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting vaccine event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _vaccineEventsController.close();
  }
}
