import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/vet_appotiment_reminder_model.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// Service to manage vet appointments.
class VetAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<VetAppointmentModel>? _cachedAppointments;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  /// Getter to access cached appointments
  List<VetAppointmentModel>? get cachedAppointments => _cachedAppointments;

  /// Fetch appointments with caching mechanism.
  Future<List<VetAppointmentModel>> getCachedAppointments(String userId) async {
    if (_cachedAppointments != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedAppointments!;
    }

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
  }

  /// Stream appointments from Firestore.
  Stream<List<VetAppointmentModel>> getVetAppointments(String userId) {
    if (_currentUser == null) {
      return Stream.value([]); // Return an empty list if no user is logged in
    }

    return _firestore
        .collection('vetAppointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return VetAppointmentModel.fromMap(doc.data());
      }).toList();

      // Sort by date
      appointments.sort((a, b) => a.date.compareTo(b.date));

      _cachedAppointments = appointments;
      _lastFetchTime = DateTime.now();

      return appointments;
    });
  }

  /// Add a new appointment to Firestore.
  Future<void> addAppointment(VetAppointmentModel appointment) async {
    await _firestore
        .collection('vetAppointments')
        .doc(appointment.id)
        .set(appointment.toMap());
    _cachedAppointments = null; // Clear cache
  }

  /// Delete an appointment and cancel related notifications.
  Future<void> deleteAppointment(VetAppointmentModel appointment) async {
    try {
      // Usuń wizytę z bazy danych
      await _firestore
          .collection('vetAppointments')
          .doc(appointment.id)
          .delete();
      _cachedAppointments = null; // Wyczyść cache
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
