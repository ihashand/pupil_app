import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/stomach_model.dart';

class StomachService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _stomachController = StreamController<List<Stomach>>.broadcast();

  Stream<List<Stomach>> getStomachStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('stomach_events')
        .snapshots()
        .listen((snapshot) {
      _stomachController
          .add(snapshot.docs.map((doc) => Stomach.fromDocument(doc)).toList());
    });

    return _stomachController.stream;
  }

  Future<void> addStomach(Stomach event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('stomach_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteStomach(String eventId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('stomach_events')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _stomachController.close();
  }
}
