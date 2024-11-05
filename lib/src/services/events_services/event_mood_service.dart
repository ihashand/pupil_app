import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';

class EventMoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<EventMoodModel>? _cachedMoods;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  Stream<List<EventMoodModel>> getMoodsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('event_moods')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventMoodModel.fromDocument(doc))
            .toList());
  }

  Future<List<EventMoodModel>> getMoodsOnce() async {
    if (_currentUser == null) {
      return [];
    }

    if (_cachedMoods != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedMoods!;
    }

    final querySnapshot = await _firestore
        .collection('event_moods')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();

    _cachedMoods = querySnapshot.docs
        .map((doc) => EventMoodModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedMoods!;
  }

  Future<void> addMood(EventMoodModel mood) async {
    await _firestore.collection('event_moods').doc(mood.id).set(mood.toMap());
    _cachedMoods = null;
  }

  Future<void> deleteMood(String moodId) async {
    await _firestore.collection('event_moods').doc(moodId).delete();
    _cachedMoods = null;
  }
}
