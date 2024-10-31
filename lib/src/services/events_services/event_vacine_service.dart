import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';

class VaccineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final _vaccineEventsController =
      StreamController<List<EventVaccineModel>>.broadcast();

  // Cache dla jednorazowych odczytów
  List<EventVaccineModel>? _cachedVaccineEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration =
      const Duration(minutes: 5); // okres ważności cache

  Future<List<EventVaccineModel>> getVaccineEventsOnce() async {
    // Sprawdzenie cache
    if (_cachedVaccineEvents != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedVaccineEvents!;
    }

    // Jeśli cache wygasł, wykonaj nowe zapytanie do Firestore
    final querySnapshot = await _firestore
        .collection('eventVaccines')
        .where('userId', isEqualTo: _currentUser?.uid)
        .get();

    _cachedVaccineEvents = querySnapshot.docs
        .map((doc) => EventVaccineModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedVaccineEvents!;
  }

  Stream<List<EventVaccineModel>> getVaccineStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('eventVaccines')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      final vaccineEvents = snapshot.docs
          .map((doc) => EventVaccineModel.fromDocument(doc))
          .toList();

      _vaccineEventsController.add(vaccineEvents);
    });

    return _vaccineEventsController.stream;
  }

  Future<void> addVaccine(EventVaccineModel vaccine) async {
    await _firestore
        .collection('eventVaccines')
        .doc(vaccine.id)
        .set(vaccine.toMap());
    _cachedVaccineEvents = null;
  }

  Future<void> deleteVaccine(String vaccineId) async {
    await _firestore.collection('eventVaccines').doc(vaccineId).delete();
    _cachedVaccineEvents = null;
  }

  void dispose() {
    _vaccineEventsController.close();
  }
}
