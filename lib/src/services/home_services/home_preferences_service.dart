import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cache to reduce unnecessary Firestore reads
  HomePreferencesModel? _cachedPreferences;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  /// Loads preferences from Firestore or cache.
  Future<void> _loadPreferences() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('Error: User is not logged in.');
      return;
    }

    // Check if cached preferences are still valid
    if (_cachedPreferences != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      state = _cachedPreferences!;
      return;
    }

    try {
      final doc = await _firestore
          .collection('app_users')
          .doc(currentUser.uid)
          .collection('preferences')
          .doc('home_preferences')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final loadedPreferences = HomePreferencesModel.fromMap(data);
          state = loadedPreferences;
          _cachedPreferences = loadedPreferences;
          _lastFetchTime = DateTime.now();
        }
      } else {
        debugPrint('No preferences found, using default.');
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Saves preferences to Firestore and updates the cache.
  Future<void> _savePreferences() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('Error: User is not logged in.');
      return;
    }

    try {
      await _firestore
          .collection('app_users')
          .doc(currentUser.uid)
          .collection('preferences')
          .doc('home_preferences')
          .set(state.toMap());
      _cachedPreferences = state;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  /// Updates the visible sections and saves preferences.
  void updateVisibleSections(List<String> newVisibleSections) {
    state = HomePreferencesModel(
      sectionOrder: state.sectionOrder,
      visibleSections: newVisibleSections,
    );
    _savePreferences();
  }

  /// Updates the order of sections and saves preferences.
  void updateSectionOrder(List<String> newSectionOrder) {
    state = HomePreferencesModel(
      sectionOrder: newSectionOrder,
      visibleSections: state.visibleSections,
    );
    _savePreferences();
  }

  /// Manually updates the entire model and saves preferences.
  Future<void> updatePreferences(HomePreferencesModel newPreferences) async {
    state = newPreferences;
    await _savePreferences();
  }
}
