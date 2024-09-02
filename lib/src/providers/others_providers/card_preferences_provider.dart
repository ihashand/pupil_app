import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/card_preferences_model.dart';

class CardPreferencesNotifier extends StateNotifier<CardPreferencesModel> {
  CardPreferencesNotifier() : super(_initialPreferences);

  static final CardPreferencesModel _initialPreferences = CardPreferencesModel(
      cardOrder: ['walkCard', 'animalCard', 'activeWalkCard']);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId = FirebaseAuth.instance.currentUser!.uid;

  void setUserId(String uid) {
    userId = uid;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('card_preferences')
        .get();
    if (doc.exists) {
      state = CardPreferencesModel.fromMap(doc.data()!);
    }
  }

  Future<void> _savePreferences() async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('card_preferences')
        .set(state.toMap());
  }

  void updateCardOrder(List<String> newCardOrder) {
    state = CardPreferencesModel(cardOrder: newCardOrder);
    _savePreferences();
  }
}

final cardPreferencesProvider =
    StateNotifierProvider<CardPreferencesNotifier, CardPreferencesModel>(
        (ref) => CardPreferencesNotifier());
