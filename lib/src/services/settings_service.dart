import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/settings_model.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveAutoRemoveSettings(SettingsModel settings) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('auto_remove')
          .set(settings.toMap());
    }
  }

  Future<SettingsModel?> getAutoRemoveSettings() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('auto_remove')
          .get();
      if (doc.exists) {
        return SettingsModel.fromDocument(doc);
      }
    }
    return null;
  }
}
