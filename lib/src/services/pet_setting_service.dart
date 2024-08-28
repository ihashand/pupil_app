import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/pet_setting_model.dart';

class PetSettingsService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Stream<PetSettingsModel?> getPetSettingsStream(String petId) {
    if (_currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('settings')
        .doc('settings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return PetSettingsModel.fromDocument(snapshot);
      } else {
        return null;
      }
    });
  }

  Future<PetSettingsModel?> getPetSettings(String petId) async {
    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser?.uid)
        .collection('pets')
        .doc(petId)
        .collection('settings')
        .doc('settings')
        .get();

    if (docSnapshot.exists) {
      return PetSettingsModel.fromDocument(docSnapshot);
    } else {
      return null;
    }
  }

  Future<void> savePetSettings(PetSettingsModel settings) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser?.uid)
        .collection('pets')
        .doc(settings.petId)
        .collection('settings')
        .doc('settings')
        .set(settings.toMap());
  }

  Future<PetSettingsModel?> getPetSettingsByPetId(String petId) async {
    final doc = await _firestore
        .collection('app_users')
        .doc(_currentUser?.uid)
        .collection('pets')
        .doc(petId)
        .collection('settings')
        .doc('settings')
        .get();
    if (doc.exists) {
      return PetSettingsModel.fromDocument(doc);
    } else {
      return null;
    }
  }
}
