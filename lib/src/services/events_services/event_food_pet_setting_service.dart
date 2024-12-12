import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_food_pet_setting_model.dart';

class EventFoodPetSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for fetched settings
  final Map<String, EventFoodPetSettingsModel?> _cachedSettings = {};

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  // Cache duration
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Timestamp for the last cache update per pet
  final Map<String, DateTime> _lastCacheUpdate = {};

  /// Stream to get real-time updates of a pet's food settings.
  Stream<EventFoodPetSettingsModel?> getPetSettingsStream(String petId) {
    if (_isCacheValid(petId)) {
      return Stream.value(_cachedSettings[petId]);
    }

    final controller = StreamController<EventFoodPetSettingsModel?>.broadcast();

    try {
      final subscription = _firestore
          .collection('event_food_settings')
          .doc(petId)
          .snapshots()
          .listen((snapshot) {
        final settings = snapshot.exists
            ? EventFoodPetSettingsModel.fromDocument(snapshot)
            : null;

        _cachedSettings[petId] = settings;
        _lastCacheUpdate[petId] = DateTime.now();

        controller.add(settings);
      }, onError: (error) {
        debugPrint(
            'Error listening to pet settings snapshots for pet $petId: $error');
        controller.addError(error);
      });

      _subscriptions.add(subscription);
      return controller.stream;
    } catch (e) {
      debugPrint('Error in getPetSettingsStream for pet $petId: $e');
      return Stream.error(e);
    }
  }

  /// Gets the current food settings for a pet.
  Future<EventFoodPetSettingsModel?> getPetSettings(String petId) async {
    if (_isCacheValid(petId)) {
      return _cachedSettings[petId];
    }

    try {
      final docSnapshot =
          await _firestore.collection('event_food_settings').doc(petId).get();

      if (docSnapshot.exists) {
        final settings = EventFoodPetSettingsModel.fromDocument(docSnapshot);
        _cachedSettings[petId] = settings;
        _lastCacheUpdate[petId] = DateTime.now();
        return settings;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching pet settings for pet $petId: $e');
      return null;
    }
  }

  /// Saves the food settings for a pet.
  Future<void> savePetSettings(EventFoodPetSettingsModel settings) async {
    try {
      await _firestore
          .collection('event_food_settings')
          .doc(settings.petId)
          .set(settings.toMap(), SetOptions(merge: true));

      _cachedSettings[settings.petId] = settings;
      _lastCacheUpdate[settings.petId] = DateTime.now();
    } catch (e) {
      debugPrint('Error saving pet settings for pet ${settings.petId}: $e');
    }
  }

  /// Deletes the food settings for a pet.
  Future<void> deletePetSettings(String petId) async {
    try {
      await _firestore.collection('event_food_settings').doc(petId).delete();

      _cachedSettings.remove(petId);
      _lastCacheUpdate.remove(petId);
    } catch (e) {
      debugPrint('Error deleting pet settings for pet $petId: $e');
    }
  }

  /// Gets all pet food settings.
  Future<List<EventFoodPetSettingsModel>> getAllPetSettings() async {
    try {
      final querySnapshot =
          await _firestore.collection('event_food_settings').get();

      final settingsList = querySnapshot.docs
          .map((doc) => EventFoodPetSettingsModel.fromDocument(doc))
          .toList();

      for (var settings in settingsList) {
        _cachedSettings[settings.petId] = settings;
        _lastCacheUpdate[settings.petId] = DateTime.now();
      }

      return settingsList;
    } catch (e) {
      debugPrint('Error fetching all pet settings: $e');
      return [];
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Helper method to check if the cache is still valid for a specific pet
  bool _isCacheValid(String petId) {
    if (!_lastCacheUpdate.containsKey(petId)) return false;
    return DateTime.now().difference(_lastCacheUpdate[petId]!) < _cacheDuration;
  }
}
