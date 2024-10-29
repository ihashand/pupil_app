import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _eventsController = StreamController<List<Event>>.broadcast();

  Stream<List<Event>> getEventsStream() {
    _firestore.collection('events').snapshots().listen((snapshot) {
      _eventsController
          .add(snapshot.docs.map((doc) => Event.fromDocument(doc)).toList());
    });

    return _eventsController.stream;
  }

  Stream<Event?> getEventByIdStream(String eventId) {
    return Stream.fromFuture(getEventById(eventId));
  }

  Future<void> addEvent(Event event, String petId) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Future<Event?> getEventById(String eventId) async {
    final docSnapshot =
        await _firestore.collection('events').doc(eventId).get();

    return docSnapshot.exists ? Event.fromDocument(docSnapshot) : null;
  }

  void dispose() {
    _eventsController.close();
  }
}
