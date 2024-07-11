import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/home_preferences_model.dart';

class HomePreferencesNotifier extends StateNotifier<HomePreferencesModel> {
  HomePreferencesNotifier() : super(_initialPreferences);

  static final HomePreferencesModel _initialPreferences = HomePreferencesModel(
    sectionOrder: [
      'AnimalCard',
      'WalkCard',
      'ActiveWalkCard',
      'ReminderCard',
      'AppointmentCard',
    ],
    visibleSections: [
      'AnimalCard',
      'WalkCard',
      'ActiveWalkCard',
      'ReminderCard',
      'AppointmentCard',
    ],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;

  void setUserId(String uid) {
    userId = uid;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('home_preferences')
        .get();
    if (doc.exists) {
      state = HomePreferencesModel.fromMap(doc.data()!);
    }
  }

  Future<void> _savePreferences() async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('home_preferences')
        .set(state.toMap());
  }

  void updateVisibleSections(List<String> newVisibleSections) {
    state = HomePreferencesModel(
      sectionOrder: state.sectionOrder,
      visibleSections: newVisibleSections,
    );
    _savePreferences();
  }

  void updateSectionOrder(List<String> newSectionOrder) {
    state = HomePreferencesModel(
      sectionOrder: newSectionOrder,
      visibleSections: state.visibleSections,
    );
    _savePreferences();
  }

  Future<void> updatePreferences(HomePreferencesModel newPreferences) async {
    state = newPreferences;
    await _savePreferences();
  }
}

final homePreferencesProvider =
    StateNotifierProvider<HomePreferencesNotifier, HomePreferencesModel>(
        (ref) => HomePreferencesNotifier());
