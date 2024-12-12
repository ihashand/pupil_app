import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/vet_appotiment_reminder_model.dart';

/// Service to manage vet appointments.
class VetAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache and subscription management
  List<VetAppointmentModel>? _cachedAppointments;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  final StreamController<List<VetAppointmentModel>> _appointmentsController =
      StreamController<List<VetAppointmentModel>>.broadcast();

  final List<StreamSubscription> _subscriptions = [];

  /// Fetch appointments with caching mechanism.
  Future<List<VetAppointmentModel>> getCachedAppointments(String userId) async {
    if (_cachedAppointments != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedAppointments!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('vetAppointments')
          .where('userId', isEqualTo: userId)
          .get();

      _cachedAppointments = querySnapshot.docs
          .map((doc) => VetAppointmentModel.fromMap(doc.data()))
          .toList();

      // Sort appointments by date
      _cachedAppointments!.sort((a, b) => a.date.compareTo(b.date));

      _lastFetchTime = DateTime.now();

      return _cachedAppointments!;
    } catch (e) {
      debugPrint('Error fetching vet appointments: $e');
      throw Exception('Failed to fetch appointments');
    }
  }

  /// Stream appointments with caching and real-time updates.
  Stream<List<VetAppointmentModel>> getVetAppointmentsStream(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    final subscription = _firestore
        .collection('vetAppointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return VetAppointmentModel.fromMap(doc.data());
      }).toList();

      // Sort by date
      appointments.sort((a, b) => a.date.compareTo(b.date));

      _cachedAppointments = appointments;
      _lastFetchTime = DateTime.now();
      _appointmentsController.add(appointments);
    }, onError: (error) {
      debugPrint('Error streaming vet appointments: $error');
      _appointmentsController.addError(error);
    });

    _subscriptions.add(subscription);
    return _appointmentsController.stream;
  }

  /// Fetch all appointments for the current user as a one-time operation.
  Future<List<VetAppointmentModel>> getVetAppointments(String userId) async {
    if (_currentUser == null) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('vetAppointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments = querySnapshot.docs.map((doc) {
        return VetAppointmentModel.fromMap(doc.data());
      }).toList();

      appointments.sort((a, b) => a.date.compareTo(b.date));

      return appointments;
    } catch (e) {
      debugPrint('Error fetching vet appointments: $e');
      return [];
    }
  }

  /// Subscribe to live updates of appointments.
  Stream<List<VetAppointmentModel>> subscribeToAppointments(String userId) {
    final controller = StreamController<List<VetAppointmentModel>>();

    final subscription = _firestore
        .collection('vetAppointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return VetAppointmentModel.fromMap(doc.data());
      }).toList();

      // Sort by date
      appointments.sort((a, b) => a.date.compareTo(b.date));

      _cachedAppointments = appointments;
      _lastFetchTime = DateTime.now();
      controller.add(appointments);
    }, onError: (error) {
      debugPrint('Error subscribing to vet appointments: $error');
      controller.addError(error);
    });

    _subscriptions.add(subscription);
    return controller.stream;
  }

  /// Add a new appointment to Firestore.
  Future<void> addAppointment(VetAppointmentModel appointment) async {
    try {
      await _firestore
          .collection('vetAppointments')
          .doc(appointment.id)
          .set(appointment.toMap());
      _cachedAppointments = null; // Clear cache
    } catch (e) {
      debugPrint('Error adding appointment: $e');
      throw Exception('Failed to add appointment');
    }
  }

  /// Delete an appointment and clear cache.
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('vetAppointments')
          .doc(appointmentId)
          .delete();
      _cachedAppointments = null; // Clear cache
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      throw Exception('Failed to delete appointment');
    }
  }

  /// Cancel all active subscriptions.
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Dispose the service to free up resources.
  void dispose() {
    cancelAllSubscriptions();
    _appointmentsController.close();
  }
}
