import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/mood_model.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _moodsController = StreamController<List<Mood>>.broadcast();

  Stream<List<Mood>> getMoodsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('moods')
        .snapshots()
        .listen((snapshot) {
      _moodsController
          .add(snapshot.docs.map((doc) => Mood.fromDocument(doc)).toList());
    });

    return _moodsController.stream;
  }

  Future<void> addMood(Mood mood) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('moods')
        .doc(mood.id)
        .set(mood.toMap());
  }

  Future<void> deleteMood(String moodId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('moods')
        .doc(moodId)
        .delete();
  }

  void dispose() {
    _moodsController.close();
  }
}
