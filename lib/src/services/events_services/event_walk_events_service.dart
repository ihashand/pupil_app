import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_walk_events_model.dart';

class EventWalkEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _urineEventsController =
      StreamController<List<EventWalkEventsModel>>.broadcast();

  Stream<List<EventWalkEventsModel>> getEventsWalksEventStream(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks_events')
        .snapshots()
        .listen((snapshot) {
      _urineEventsController.add(snapshot.docs
          .map((doc) => EventWalkEventsModel.fromDocument(doc))
          .toList());
    });

    return _urineEventsController.stream;
  }

  Future<void> addEventsWalkEvent(
      EventWalkEventsModel event, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_walks_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteEventsWalkEvent(String eventId, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_walks_events')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _urineEventsController.close();
  }
}
