import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_service_event_model.dart';

class EventServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting service events stream
  final StreamController<List<EventServiceModel>> _servicesEventController =
      StreamController<List<EventServiceModel>>.broadcast();

  // Cache for fetched service events
  List<EventServiceModel>? _cachedServices;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of service events.
  Stream<List<EventServiceModel>> getServicesEventStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedServices != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _servicesEventController.add(_cachedServices!);
      } else {
        final subscription = _firestore
            .collection('event_services')
            .snapshots()
            .listen((snapshot) {
          final services = snapshot.docs
              .map((doc) => EventServiceModel.fromDocument(doc))
              .toList();
          _cachedServices = services;
          _lastFetchTime = DateTime.now();
          _servicesEventController.add(services);
        }, onError: (error) {
          debugPrint('Error listening to services stream: $error');
          _servicesEventController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _servicesEventController.stream;
    } catch (e) {
      debugPrint('Error in getServicesEventStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new service event.
  Future<void> addServiceEvent(EventServiceModel service) async {
    try {
      await _firestore
          .collection('event_services')
          .doc(service.id)
          .set(service.toMap());
      _cachedServices = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding service event: $e');
    }
  }

  /// Deletes a service event by ID.
  Future<void> deleteServiceEvent(String serviceId) async {
    try {
      await _firestore.collection('event_services').doc(serviceId).delete();
      _cachedServices?.removeWhere((service) => service.id == serviceId);
      _servicesEventController
          .add(_cachedServices!); // Update stream after deletion
    } catch (e) {
      debugPrint('Error deleting service event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _servicesEventController.close();
  }
}
