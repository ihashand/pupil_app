import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:pet_diary/src/data/services/local_medicine_service.dart';
import 'package:pet_diary/src/models/medicine_model.dart';

class SyncMedicineService {
  static final _firestore = FirebaseFirestore.instance;
  static final _currentUser = FirebaseAuth.instance.currentUser;
  static final _medicineBox = Hive.box<Medicine>('medicineBox');
  static final _localMedicineService = LocalMedicineService(_medicineBox);

  static Future<void> syncData() async {
    if (_currentUser == null) return;

    final localMedicines = _localMedicineService.getAllMedicines();
    for (var medicine in localMedicines) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('medicines')
          .doc(medicine.id)
          .set(medicine.toMap(), SetOptions(merge: true));
    }
  }

  static Future<void> addMedicine(Medicine medicine) async {
    await _localMedicineService.addMedicine(medicine);
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap(), SetOptions(merge: true));
  }

  static Future<void> updateMedicine(Medicine medicine) async {
    await _localMedicineService.updateMedicine(medicine);
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap(), SetOptions(merge: true));
  }

  static Future<void> deleteMedicine(String id) async {
    await _localMedicineService.deleteMedicine(id);
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('medicines')
        .doc(id)
        .delete();
  }
}
