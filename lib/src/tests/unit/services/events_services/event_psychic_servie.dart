import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_psychic_model.dart';

class EventPsychicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _psychicEventsController =
      StreamController<List<EventPsychicModel>>.broadcast();

  Stream<List<EventPsychicModel>> getPsychicEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_psychics')
        .snapshots()
        .listen((snapshot) {
      _psychicEventsController.add(snapshot.docs
          .map((doc) => EventPsychicModel.fromDocument(doc))
          .toList());
    });

    return _psychicEventsController.stream;
  }

  Future<void> addPsychicEvent(EventPsychicModel event) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_psychics')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deletePsychicEvent(String eventId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_psychics')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _psychicEventsController.close();
  }
}
