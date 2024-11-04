// EventMedicineService.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';

class EventMedicineService {
  final FirebaseFirestore _firestore;
  final User? _currentUser;
  final Map<String, EventMedicineModel> _cache = {};

  final _medicineController =
      StreamController<List<EventMedicineModel>>.broadcast();

  EventMedicineService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = auth?.currentUser ?? FirebaseAuth.instance.currentUser;

  Stream<List<EventMedicineModel>> getPills() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore.collection('event_medicines').snapshots().map((snapshot) {
      final pills = snapshot.docs.map((doc) {
        final medicine = EventMedicineModel.fromDocument(doc);
        _cache[medicine.id] = medicine;
        return medicine;
      }).toList();
      _medicineController.add(pills);
      return pills;
    });
  }

  Stream<EventMedicineModel?> getMedicineByIdStream(String medicineId) {
    return Stream.fromFuture(getMedicineById(medicineId));
  }

  Future<EventMedicineModel?> getMedicineById(String medicineId) async {
    if (_currentUser == null) {
      return null;
    }

    if (_cache.containsKey(medicineId)) {
      return _cache[medicineId];
    }

    final docSnapshot =
        await _firestore.collection('event_medicines').doc(medicineId).get();

    if (docSnapshot.exists) {
      final medicine = EventMedicineModel.fromDocument(docSnapshot);
      _cache[medicineId] = medicine;
      return medicine;
    } else {
      return null;
    }
  }

  Future<void> addMedicine(EventMedicineModel medicine) async {
    await _firestore
        .collection('event_medicines')
        .doc(medicine.id)
        .set(medicine.toMap());
    _cache[medicine.id] = medicine;
  }

  Future<void> updateMedicine(EventMedicineModel medicine) async {
    await _firestore
        .collection('event_medicines')
        .doc(medicine.id)
        .update(medicine.toMap());
    _cache[medicine.id] = medicine;
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _firestore.collection('event_medicines').doc(medicineId).delete();
    _cache.remove(medicineId);
  }

  void dispose() {
    _medicineController.close();
  }

  Future<void> updateExistingRecordsWithTimes() async {
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
  }
}
