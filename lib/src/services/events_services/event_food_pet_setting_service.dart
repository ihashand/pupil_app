import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_food_pet_setting_model.dart';

class EventFoodPetSettingsService {
  final _firestore = FirebaseFirestore.instance;

  Stream<EventFoodPetSettingsModel?> getPetSettingsStream(String petId) {
    return _firestore
        .collection('event_food_settings')
        .doc(petId)
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
    final docSnapshot =
        await _firestore.collection('event_food_settings').doc(petId).get();

    if (docSnapshot.exists) {
      return EventFoodPetSettingsModel.fromDocument(docSnapshot);
    } else {
      return null;
    }
  }

  Future<void> savePetSettings(EventFoodPetSettingsModel settings) async {
    await _firestore
        .collection('event_food_settings')
        .doc(settings.petId)
        .set(settings.toMap(), SetOptions(merge: true));
  }

  Future<void> deletePetSettings(String petId) async {
    await _firestore.collection('event_food_settings').doc(petId).delete();
  }

  Future<List<EventFoodPetSettingsModel>> getAllPetSettings() async {
    final querySnapshot =
        await _firestore.collection('event_food_settings').get();

    return querySnapshot.docs
        .map((doc) => EventFoodPetSettingsModel.fromDocument(doc))
        .toList();
  }
}
