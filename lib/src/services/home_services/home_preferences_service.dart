import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/others/home_preferences_model.dart';

class HomePreferencesService extends StateNotifier<HomePreferencesModel> {
  HomePreferencesService() : super(_initialPreferences) {
    _loadPreferences();
  }

  static final HomePreferencesModel _initialPreferences = HomePreferencesModel(
    sectionOrder: [
      'AnimalCard',
      'FriendRequestsCard',
      'WalkCard',
      'ActiveWalkCard',
      'ReminderCard',
      'AppointmentCard',
    ],
    visibleSections: [
      'AnimalCard',
      'FriendRequestsCard',
      'WalkCard',
      'ActiveWalkCard',
      'ReminderCard',
      'AppointmentCard',
    ],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  /// Ładowanie preferencji z bazy danych
  Future<void> _loadPreferences() async {
    if (_currentUser == null) return;

    final doc = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('preferences')
        .doc('home_preferences')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final loadedPreferences = HomePreferencesModel.fromMap(data);
        state = loadedPreferences;
      }
    }
  }

  /// Zapisywanie preferencji do bazy danych
  Future<void> _savePreferences() async {
    if (_currentUser == null) return;

    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('preferences')
        .doc('home_preferences')
        .set(state.toMap());
  }

  /// Aktualizacja widocznych sekcji
  void updateVisibleSections(List<String> newVisibleSections) {
    state = HomePreferencesModel(
      sectionOrder: state.sectionOrder,
      visibleSections: newVisibleSections,
    );
    _savePreferences();
  }

  /// Aktualizacja kolejności sekcji
  void updateSectionOrder(List<String> newSectionOrder) {
    state = HomePreferencesModel(
      sectionOrder: newSectionOrder,
      visibleSections: state.visibleSections,
    );
    _savePreferences();
  }

  /// Ręczna aktualizacja całego modelu
  Future<void> updatePreferences(HomePreferencesModel newPreferences) async {
    state = newPreferences;
    await _savePreferences();
  }
}
