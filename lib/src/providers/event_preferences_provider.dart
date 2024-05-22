import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_preferences.dart';

class PreferencesNotifier extends StateNotifier<PreferencesModel> {
  PreferencesNotifier() : super(_initialPreferences);

  static final PreferencesModel _initialPreferences = PreferencesModel(
    sectionOrder: [
      'Lifestyle',
      'Care',
      'Services',
      'Psychic Issues',
      'Stool Type',
      'Urine Color',
      'Mood',
      'Stomach Issues',
      'Notes',
      'Meds',
    ],
    visibleSections: [
      'Lifestyle',
      'Care',
      'Services',
      'Psychic Issues',
      'Stool Type',
      'Urine Color',
      'Mood',
      'Stomach Issues',
      'Notes',
      'Meds',
    ],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;
  late String petId;

  void setUserIdAndPetId(String uid, String pid) {
    userId = uid;
    petId = pid;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .collection('preferences')
        .doc('event_preferences')
        .get();
    if (doc.exists) {
      state = PreferencesModel.fromMap(doc.data()!);
    }
  }

  Future<void> _savePreferences() async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .collection('preferences')
        .doc('event_preferences')
        .set(state.toMap());
  }

  void updateVisibleSections(List<String> newVisibleSections) {
    state = PreferencesModel(
      sectionOrder: state.sectionOrder,
      visibleSections: newVisibleSections,
    );
    _savePreferences();
  }

  void updateSectionOrder(List<String> newSectionOrder) {
    state = PreferencesModel(
      sectionOrder: newSectionOrder,
      visibleSections: state.visibleSections,
    );
    _savePreferences();
  }

  Future<void> updatePreferences(PreferencesModel newPreferences) async {
    state = newPreferences;
    await _savePreferences();
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesModel>(
        (ref) => PreferencesNotifier());
