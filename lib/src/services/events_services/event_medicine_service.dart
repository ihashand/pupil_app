import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';

class EventMedicineService {
  final FirebaseFirestore _firestore;
  final User? _currentUser;

  // Cache for storing medicine data
  final Map<String, EventMedicineModel> _cache = {};

  // StreamController for broadcasting medicine stream
  final StreamController<List<EventMedicineModel>> _medicineController =
      StreamController<List<EventMedicineModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  EventMedicineService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = auth?.currentUser ?? FirebaseAuth.instance.currentUser;

  /// Stream to get all pills.
  Stream<List<EventMedicineModel>> getPills() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      final subscription = _firestore
          .collection('event_medicines')
          .snapshots()
          .listen((snapshot) {
        final pills = snapshot.docs.map((doc) {
          final medicine = EventMedicineModel.fromDocument(doc);
          _cache[medicine.id] = medicine;
          return medicine;
        }).toList();
        _medicineController.add(pills);
      }, onError: (error) {
        debugPrint('Error fetching pills: $error');
        _medicineController.addError(error);
      });

      _subscriptions.add(subscription);
      return _medicineController.stream;
    } catch (e) {
      debugPrint('Error in getPills: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get a single medicine by ID.
  Stream<EventMedicineModel?> getMedicineByIdStream(String medicineId) {
    return Stream.fromFuture(getMedicineById(medicineId));
  }

  /// Fetches a single medicine by ID.
  Future<EventMedicineModel?> getMedicineById(String medicineId) async {
    if (_currentUser == null) {
      return null;
    }

    if (_cache.containsKey(medicineId)) {
      return _cache[medicineId];
    }

    try {
      final docSnapshot =
          await _firestore.collection('event_medicines').doc(medicineId).get();

      if (docSnapshot.exists) {
        final medicine = EventMedicineModel.fromDocument(docSnapshot);
        _cache[medicineId] = medicine;
        return medicine;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching medicine by ID: $e');
      return null;
    }
  }

  /// Adds a new medicine to Firestore.
  Future<void> addMedicine(EventMedicineModel medicine) async {
    try {
      await _firestore
          .collection('event_medicines')
          .doc(medicine.id)
          .set(medicine.toMap());
      _cache[medicine.id] = medicine;
    } catch (e) {
      debugPrint('Error adding medicine: $e');
    }
  }

  /// Updates an existing medicine in Firestore.
  Future<void> updateMedicine(EventMedicineModel medicine) async {
    try {
      await _firestore
          .collection('event_medicines')
          .doc(medicine.id)
          .update(medicine.toMap());
      _cache[medicine.id] = medicine;
    } catch (e) {
      debugPrint('Error updating medicine: $e');
    }
  }

  /// Deletes a medicine from Firestore.
  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _firestore.collection('event_medicines').doc(medicineId).delete();
      _cache.remove(medicineId);
    } catch (e) {
      debugPrint('Error deleting medicine: $e');
    }
  }

  /// Updates existing records by adding 'times' field if missing.
  Future<void> updateExistingRecordsWithTimes() async {
    try {
      final medicinesSnapshot =
          await _firestore.collection('event_medicines').get();

      for (var doc in medicinesSnapshot.docs) {
        final data = doc.data();

        if (!data.containsKey('times')) {
          await doc.reference.update({
            'times': [],
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating records with times: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _medicineController.close();
  }
}
