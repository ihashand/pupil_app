import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/vet_appotiment_reminder_model.dart';

/// Service to manage vet appointments.
class VetAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<VetAppointmentModel>? _cachedAppointments;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _appointmentsSubscription;

  /// Getter to access cached appointments
  List<VetAppointmentModel>? get cachedAppointments => _cachedAppointments;

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
      print('Error fetching vet appointments: $e');
      throw Exception('Failed to fetch appointments');
    }
  }

  /// Stream appointments from Firestore with live updates.
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

  /// Subscribe to live updates of appointments.
  Stream<List<VetAppointmentModel>> subscribeToAppointments(String userId) {
    final controller = StreamController<List<VetAppointmentModel>>();

    _appointmentsSubscription = _firestore
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
      print('Error subscribing to vet appointments: $error');
      controller.addError(error);
    });

    return controller.stream;
  }

  /// Cancel the active subscription to Firestore.
  void cancelSubscription() {
    _appointmentsSubscription?.cancel();
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
      print('Error adding appointment: $e');
      throw Exception('Failed to add appointment');
    }
  }

  /// Delete an appointment and cancel related notifications.
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('vetAppointments')
          .doc(appointmentId)
          .delete();
      _cachedAppointments = null; // Clear cache
    } catch (e) {
      print('Error deleting appointment: $e');
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
