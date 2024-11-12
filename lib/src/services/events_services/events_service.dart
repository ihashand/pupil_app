import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _eventsController = StreamController<List<Event>>.broadcast();
  final Map<String, Event> _cache = {};

  Stream<List<Event>> getEventsStream() {
    _firestore.collection('events').snapshots().listen((snapshot) {
      final events = snapshot.docs.map((doc) {
        final event = Event.fromDocument(doc);
        _cache[event.id] = event;
        return event;
      }).toList();
      _eventsController.add(events);
    });

    return _eventsController.stream;
  }

  Stream<Event?> getEventByIdStream(String eventId) {
    return Stream.fromFuture(getEventById(eventId));
  }

  Future<Event?> getEventById(String eventId) async {
    if (_cache.containsKey(eventId)) {
      return _cache[eventId];
    }

    final docSnapshot =
        await _firestore.collection('events').doc(eventId).get();

    if (docSnapshot.exists) {
      final event = Event.fromDocument(docSnapshot);
      _cache[eventId] = event;
      return event;
    } else {
      return null;
    }
  }

  Future<void> addEvent(Event event, String petId) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
    _cache[event.id] = event;
  }

  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
    _cache[event.id] = event;
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
    _cache.remove(eventId);
  }

  Future<List<Event>> getEventsByPillId(String pillId) async {
    final querySnapshot = await _firestore
        .collection('events')
        .where('pillId', isEqualTo: pillId)
        .get();

    final events = querySnapshot.docs.map((doc) {
      final event = Event.fromDocument(doc);
      _cache[event.id] = event;
      return event;
    }).toList();

    return events;
  }

  void dispose() {
    _eventsController.close();
  }
}
