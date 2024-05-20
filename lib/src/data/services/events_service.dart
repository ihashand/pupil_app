import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _eventsController = StreamController<List<Event>>.broadcast();

  Stream<List<Event>> getEventsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      _eventsController
          .add(snapshot.docs.map((doc) => Event.fromDocument(doc)).toList());
    });

    return _eventsController.stream;
  }

  Stream<Event?> getEventByIdStream(String petId) {
    return Stream.fromFuture(getEventById(petId));
  }

  Future<void> addEvent(Event event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('events')
        .doc(event.id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  Future<Event?> getEventById(String eventId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('events')
        .doc(eventId)
        .get();

    return docSnapshot.exists ? Event.fromDocument(docSnapshot) : null;
  }

  void dispose() {
    _eventsController.close();
  }
}
