import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';

class EventUrineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _urineEventsController =
      StreamController<List<EventUrineModel>>.broadcast();

  Stream<List<EventUrineModel>> getUrineEventsStream(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_urines')
        .snapshots()
        .listen((snapshot) {
      _urineEventsController.add(snapshot.docs
          .map((doc) => EventUrineModel.fromDocument(doc))
          .toList());
    });

    return _urineEventsController.stream;
  }

  Future<void> addUrineEvent(EventUrineModel event, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_urines')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteUrineEvent(String eventId, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_urines')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _urineEventsController.close();
  }
}
