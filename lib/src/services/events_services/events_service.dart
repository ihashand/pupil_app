import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/events_models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _eventsController = StreamController<List<Event>>.broadcast();

  Stream<List<Event>> getEventsStream(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      _eventsController
          .add(snapshot.docs.map((doc) => Event.fromDocument(doc)).toList());
    });

    return _eventsController.stream;
  }

  Stream<Event?> getEventByIdStream(String eventId, String petId) {
    return Stream.fromFuture(getEventById(eventId, petId));
  }

  Future<void> addEvent(Event event, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> updateEvent(Event event, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('events')
        .doc(event.id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String eventId, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  Future<Event?> getEventById(String eventId, String petId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('events')
        .doc(eventId)
        .get();

    return docSnapshot.exists ? Event.fromDocument(docSnapshot) : null;
  }

  void dispose() {
    _eventsController.close();
  }
}
