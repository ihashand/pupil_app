import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/psychic_model.dart';

class PsychicEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _psychicEventsController =
      StreamController<List<PsychicEvent>>.broadcast();

  Stream<List<PsychicEvent>> getPsychicEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('psychic_events')
        .snapshots()
        .listen((snapshot) {
      _psychicEventsController.add(
          snapshot.docs.map((doc) => PsychicEvent.fromDocument(doc)).toList());
    });

    return _psychicEventsController.stream;
  }

  Future<void> addPsychicEvent(PsychicEvent event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('psychic_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deletePsychicEvent(String eventId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('psychic_events')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _psychicEventsController.close();
  }
}
