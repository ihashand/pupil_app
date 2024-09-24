import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/others/home_preferences_model.dart';

class HomePreferencesService extends StateNotifier<HomePreferencesModel> {
  HomePreferencesService() : super(_initialPreferences);

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

  Future<void> _savePreferences() async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
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
