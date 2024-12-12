import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_temperature_model.dart';

class EventTemperatureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache duration and data
  final Duration _cacheDuration = const Duration(minutes: 5);
  List<EventTemperatureModel>? _cachedTemperatures;
  DateTime? _lastFetchTime;

  // StreamController for broadcasting temperature events stream
  final StreamController<List<EventTemperatureModel>> _temperatureController =
      StreamController<List<EventTemperatureModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of temperature events.
  Stream<List<EventTemperatureModel>> getTemperatureStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedTemperatures != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _temperatureController.add(_cachedTemperatures!);
      } else {
        final subscription = _firestore
            .collection('event_temperatures')
            .where('userId', isEqualTo: _currentUser.uid)
            .snapshots()
            .listen((snapshot) {
          final temperatures = snapshot.docs
              .map((doc) => EventTemperatureModel.fromDocument(doc))
              .toList();
          _cachedTemperatures = temperatures;
          _lastFetchTime = DateTime.now();
          _temperatureController.add(temperatures);
        }, onError: (error) {
          debugPrint('Error listening to temperature stream: $error');
          _temperatureController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _temperatureController.stream;
    } catch (e) {
      debugPrint('Error in getTemperatureStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetches temperature events once and caches the result.
  Future<List<EventTemperatureModel>> getTemperaturesOnce() async {
    if (_cachedTemperatures != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedTemperatures!;
    }

    if (_currentUser == null) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('event_temperatures')
          .where('userId', isEqualTo: _currentUser.uid)
          .get();

      _cachedTemperatures = querySnapshot.docs
          .map((doc) => EventTemperatureModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedTemperatures!;
    } catch (e) {
      debugPrint('Error fetching temperatures once: $e');
      return [];
    }
  }

  /// Fetches a single temperature event by ID.
  Future<EventTemperatureModel?> getTemperatureById(
      String temperatureId) async {
    if (_currentUser == null) {
      return null;
    }

    try {
      final docSnapshot = await _firestore
          .collection('event_temperatures')
          .doc(temperatureId)
          .get();

      return docSnapshot.exists
          ? EventTemperatureModel.fromDocument(docSnapshot)
          : null;
    } catch (e) {
      debugPrint('Error fetching temperature by ID: $e');
      return null;
    }
  }

  /// Adds a new temperature event.
  Future<void> addTemperature(EventTemperatureModel temperature) async {
    try {
      await _firestore
          .collection('event_temperatures')
          .doc(temperature.id)
          .set(temperature.toMap());
      _cachedTemperatures = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding temperature event: $e');
    }
  }

  /// Updates an existing temperature event.
  Future<void> updateTemperature(EventTemperatureModel temperature) async {
    try {
      await _firestore
          .collection('event_temperatures')
          .doc(temperature.id)
          .update(temperature.toMap());
      _cachedTemperatures = null; // Invalidate cache after updating
    } catch (e) {
      debugPrint('Error updating temperature event: $e');
    }
  }

  /// Deletes a temperature event by ID.
  Future<void> deleteTemperature(String temperatureId) async {
    try {
      await _firestore
          .collection('event_temperatures')
          .doc(temperatureId)
          .delete();
      _cachedTemperatures = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting temperature event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _temperatureController.close();
  }
}
