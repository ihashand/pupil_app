import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';

class EventMedicineService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _medicineController =
      StreamController<List<EventMedicineModel>>.broadcast();

  Stream<List<EventMedicineModel>> getPills() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore.collection('event_medicines').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EventMedicineModel.fromDocument(doc))
          .toList();
    });
  }

  Stream<EventMedicineModel?> getMedicineByIdStream(String medicineId) {
    return Stream.fromFuture(getMedicineById(medicineId));
  }

  Future<EventMedicineModel?> getMedicineById(String medicineId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot =
        await _firestore.collection('event_medicines').doc(medicineId).get();

    return docSnapshot.exists
        ? EventMedicineModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addMedicine(EventMedicineModel medicine) async {
    await _firestore
        .collection('event_medicines')
        .doc(medicine.id)
        .set(medicine.toMap());
  }

  Future<void> updateMedicine(EventMedicineModel medicine) async {
    await _firestore
        .collection('event_medicines')
        .doc(medicine.id)
        .update(medicine.toMap());
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _firestore.collection('event_medicines').doc(medicineId).delete();
  }

  void dispose() {
    _medicineController.close();
  }
}
