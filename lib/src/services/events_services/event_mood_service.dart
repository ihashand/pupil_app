import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';

class EventMoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _moodsController = StreamController<List<EventMoodModel>>.broadcast();

  Stream<List<EventMoodModel>> getMoodsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_moods')
        .snapshots()
        .listen((snapshot) {
      _moodsController.add(snapshot.docs
          .map((doc) => EventMoodModel.fromDocument(doc))
          .toList());
    });

    return _moodsController.stream;
  }

  Future<void> addMood(EventMoodModel mood) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_moods')
        .doc(mood.id)
        .set(mood.toMap());
  }

  Future<void> deleteMood(String moodId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_moods')
        .doc(moodId)
        .delete();
  }

  void dispose() {
    _moodsController.close();
  }
}
