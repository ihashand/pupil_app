import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';

class EventMoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache for one-time reads
  List<EventMoodModel>? _cachedMoods;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // StreamController for broadcasting mood events stream
  final StreamController<List<EventMoodModel>> _moodController =
      StreamController<List<EventMoodModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of mood events.
  Stream<List<EventMoodModel>> getMoodsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      final subscription = _firestore
          .collection('event_moods')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        final moods = snapshot.docs
            .map((doc) => EventMoodModel.fromDocument(doc))
            .toList();
        _moodController.add(moods);
      }, onError: (error) {
        debugPrint('Error listening to moods stream: $error');
        _moodController.addError(error);
      });

      _subscriptions.add(subscription);
      return _moodController.stream;
    } catch (e) {
      debugPrint('Error in getMoodsStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetches mood events once and caches the result.
  Future<List<EventMoodModel>> getMoodsOnce() async {
    if (_currentUser == null) {
      return [];
    }

    if (_cachedMoods != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedMoods!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('event_moods')
          .where('userId', isEqualTo: _currentUser.uid)
          .get();

      _cachedMoods = querySnapshot.docs
          .map((doc) => EventMoodModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedMoods!;
    } catch (e) {
      debugPrint('Error fetching moods once: $e');
      return [];
    }
  }

  /// Adds a new mood event.
  Future<void> addMood(EventMoodModel mood) async {
    try {
      await _firestore.collection('event_moods').doc(mood.id).set(mood.toMap());
      _cachedMoods = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding mood event: $e');
    }
  }

  /// Deletes a mood event by ID.
  Future<void> deleteMood(String moodId) async {
    try {
      await _firestore.collection('event_moods').doc(moodId).delete();
      _cachedMoods = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting mood event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _moodController.close();
  }
}
