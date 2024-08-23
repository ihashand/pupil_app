import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/pet_setting_model.dart';

class PetSettingsService {
  final _firestore = FirebaseFirestore.instance;

  Future<PetSettingsModel?> getPetSettings(String petId) async {
    final snapshot = await _firestore
        .collection('pet_settings')
        .where('petId', isEqualTo: petId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return PetSettingsModel.fromDocument(snapshot.docs.first);
    }
    return null;
  }

  Future<void> savePetSettings(PetSettingsModel settings) async {
    await _firestore
        .collection('pet_settings')
        .doc(settings.id)
        .set(settings.toMap());
  }

  Future<void> updatePetSettings(PetSettingsModel settings) async {
    await _firestore
        .collection('pet_settings')
        .doc(settings.id)
        .update(settings.toMap());
  }
}
