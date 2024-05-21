import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/stool_event_model.dart';

class StoolEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _stoolEventsController = StreamController<List<StoolEvent>>.broadcast();

  Stream<List<StoolEvent>> getStoolEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('stool_events')
        .snapshots()
        .listen((snapshot) {
      _stoolEventsController.add(
          snapshot.docs.map((doc) => StoolEvent.fromDocument(doc)).toList());
    });

    return _stoolEventsController.stream;
  }

  Future<void> addStoolEvent(StoolEvent event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('stool_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteStoolEvent(String eventId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('stool_events')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _stoolEventsController.close();
  }
}
