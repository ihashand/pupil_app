import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/pill_model.dart';

class PillService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _medicineController = StreamController<List<Medicine>>.broadcast();

  Stream<List<Medicine>> getPills() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('medicines')
        .snapshots()
        .listen((snapshot) {
      _medicineController
          .add(snapshot.docs.map((doc) => Medicine.fromDocument(doc)).toList());
    });

    return _medicineController.stream;
  }

  Stream<Medicine?> getMedicineByIdStream(String medicineId) {
    return Stream.fromFuture(getMedicineById(medicineId));
  }

  Future<Medicine?> getMedicineById(String medicineId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('medicines')
        .doc(medicineId)
        .get();

    return docSnapshot.exists ? Medicine.fromDocument(docSnapshot) : null;
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap());
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('medicines')
        .doc(medicine.id)
        .update(medicine.toMap());
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('medicines')
        .doc(medicineId)
        .delete();
  }

  void dispose() {
    _medicineController.close();
  }
}
