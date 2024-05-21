import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/urine_event_model.dart';

class UrineEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _urineEventsController = StreamController<List<UrineEvent>>.broadcast();

  Stream<List<UrineEvent>> getUrineEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('urine_events')
        .snapshots()
        .listen((snapshot) {
      _urineEventsController.add(
          snapshot.docs.map((doc) => UrineEvent.fromDocument(doc)).toList());
    });

    return _urineEventsController.stream;
  }

  Future<void> addUrineEvent(UrineEvent event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('urine_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteUrineEvent(String eventId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('urine_events')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _urineEventsController.close();
  }
}
