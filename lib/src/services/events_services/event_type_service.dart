import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventTypeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Cache for user preferences
  DocumentSnapshot? _cachedPreferences;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  /// Fetches user event type preferences from Firestore with cache support.
  Future<DocumentSnapshot> getUserEventTypePreferences() async {
    if (_cachedPreferences != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedPreferences!;
    }

    try {
      final preferences = await _firestore
          .collection('app_users')
          .doc(userId)
          .collection('preferences')
          .doc('health_event_preferences')
          .get();
      _cachedPreferences = preferences;
      _lastFetchTime = DateTime.now();
      return preferences;
    } catch (e) {
      debugPrint('Error fetching user event type preferences: $e');
      rethrow;
    }
  }

  /// Saves user event type preferences to Firestore and invalidates cache.
  Future<void> saveUserEventTypePreferences(
      List<Map<String, dynamic>> eventTypeCards) async {
    try {
      await _firestore
          .collection('app_users')
          .doc(userId)
          .collection('preferences')
          .doc('health_event_preferences')
          .set({
        'eventTypeCards': eventTypeCards,
      });
      _cachedPreferences = null; // Invalidate cache after saving
    } catch (e) {
      debugPrint('Error saving user event type preferences: $e');
      rethrow;
    }
  }

  /// Initializes user event type preferences in Firestore if they do not already exist.
  Future<void> initializeEventTypePreferences() async {
    try {
      final userPreferences = await getUserEventTypePreferences();

      if (!userPreferences.exists) {
        await saveUserEventTypePreferences([
          {
            'widget': 'eventTypeCardWater',
            'isActive': true,
            'keywords': [
              'water',
              'hydration',
              'fluid intake',
              'thirst',
              'wellness',
              'health',
              'refreshment'
            ]
          },
          {
            'widget': 'eventTypeCardFood',
            'isActive': true,
            'keywords': [
              'food',
              'nutrition',
              'diet',
              'meals',
              'feeding',
              'health',
              'wellbeing'
            ]
          },
          {
            'widget': 'eventTypeCardMedicine',
            'isActive': true,
            'keywords': [
              'medicine',
              'medication',
              'treatment',
              'prescription',
              'healthcare',
              'wellness',
              'therapy'
            ]
          },
          {
            'widget': 'eventTypeCardVaccines',
            'isActive': true,
            'keywords': [
              'vaccines',
              'health',
              'immunization',
              'protection',
              'prevention',
              'wellness',
              'safety'
            ]
          },
          {
            'widget': 'eventTypeCardMood',
            'isActive': true,
            'keywords': [
              'mood',
              'heart',
              'love',
              'sad',
              'cry',
              'emotions',
              'feelings'
            ]
          },
          {
            'widget': 'eventTypeCardIssues',
            'isActive': true,
            'keywords': [
              'issues',
              'problems',
              'concerns',
              'health',
              'behavior',
              'symptoms',
              'troubles'
            ]
          },
          {
            'widget': 'eventTypeCardCare',
            'isActive': true,
            'keywords': [
              'care',
              'grooming',
              'maintenance',
              'hygiene',
              'wellness',
              'support',
              'attention'
            ]
          },
          {
            'widget': 'eventTypeCardStool',
            'isActive': true,
            'keywords': [
              'stool',
              'bowel',
              'digestion',
              'health',
              'wellness',
              'monitoring',
              'excretion'
            ]
          },
          {
            'widget': 'eventTypeCardUrine',
            'isActive': true,
            'keywords': [
              'urine',
              'pee',
              'water',
              'hydration',
              'health',
              'monitoring',
              'excretion'
            ]
          },
          {
            'widget': 'eventTypeCardWeight',
            'isActive': true,
            'keywords': [
              'weight',
              'mass',
              'measurement',
              'health',
              'wellness',
              'tracking',
              'fitness'
            ]
          },
          {
            'widget': 'eventTypeCardTemperature',
            'isActive': true,
            'keywords': [
              'temperature',
              'heat',
              'body temperature',
              'health',
              'monitoring',
              'wellness',
              'fever'
            ]
          },
          {
            'widget': 'eventTypeCardWalk',
            'isActive': true,
            'keywords': [
              'walk',
            ]
          },
          {
            'widget': 'eventTypeCardNotes',
            'isActive': true,
            'keywords': [
              'notes',
              'journal',
              'records',
              'observations',
              'tracking',
              'information',
              'documentation'
            ]
          }
        ]);
      }
    } catch (e) {
      debugPrint('Error initializing event type preferences: $e');
      rethrow;
    }
  }
}
