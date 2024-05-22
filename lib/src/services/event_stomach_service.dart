import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_stomach_model.dart';

class EventStomachService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _stomachController =
      StreamController<List<EventStomachModel>>.broadcast();

  Stream<List<EventStomachModel>> getStomachStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_stomachs')
        .snapshots()
        .listen((snapshot) {
      _stomachController.add(snapshot.docs
          .map((doc) => EventStomachModel.fromDocument(doc))
          .toList());
    });

    return _stomachController.stream;
  }

  Future<void> addStomach(EventStomachModel event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_stomachs')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteStomach(String eventId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_stomachs')
        .doc(eventId)
        .delete();
  }

  void dispose() {
    _stomachController.close();
  }
}
