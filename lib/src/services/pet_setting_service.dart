import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_food_pet_setting_model.dart';

class PetSettingsService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Stream<EventFoodPetSettingsModel?> getPetSettingsStream(String petId) {
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
        return EventFoodPetSettingsModel.fromDocument(snapshot);
      } else {
        return null;
      }
    });
  }

  Future<EventFoodPetSettingsModel?> getPetSettings(String petId) async {
    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser?.uid)
        .collection('pets')
        .doc(petId)
        .collection('settings')
        .doc('settings')
        .get();

    if (docSnapshot.exists) {
      return EventFoodPetSettingsModel.fromDocument(docSnapshot);
    } else {
      return null;
    }
  }

  Future<void> savePetSettings(EventFoodPetSettingsModel settings) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser?.uid)
        .collection('pets')
        .doc(settings.petId)
        .collection('settings')
        .doc('settings')
        .set(settings.toMap());
  }

  Future<EventFoodPetSettingsModel?> getPetSettingsByPetId(String petId) async {
    final doc = await _firestore
        .collection('app_users')
        .doc(_currentUser?.uid)
        .collection('pets')
        .doc(petId)
        .collection('settings')
        .doc('settings')
        .get();
    if (doc.exists) {
      return EventFoodPetSettingsModel.fromDocument(doc);
    } else {
      return null;
    }
  }
}
