import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';

class EventStoolService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _stoolEventsController =
      StreamController<List<EventStoolModel>>.broadcast();

  Stream<List<EventStoolModel>> getStoolEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_stools')
        .snapshots()
        .listen((snapshot) {
      _stoolEventsController.add(snapshot.docs
          .map((doc) => EventStoolModel.fromDocument(doc))
          .toList());
    });

    return _stoolEventsController.stream;
  }

  Future<void> addStoolEvent(EventStoolModel event) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_stools')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteStoolEvent(String eventId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_stools')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _stoolEventsController.close();
  }
}
