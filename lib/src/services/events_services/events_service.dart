import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // StreamController for broadcasting event stream
  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();

  // Cache for fetched events
  final Map<String, Event> _cache = {};

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of all events.
  Stream<List<Event>> getEventsStream() {
    try {
      final subscription = _firestore.collection('events').snapshots().listen(
        (snapshot) {
          final events = snapshot.docs.map((doc) {
            final event = Event.fromDocument(doc);
            _cache[event.id] = event;
            return event;
          }).toList();
          _eventsController.add(events);
        },
        onError: (error) {
          debugPrint('Error listening to events stream: $error');
          _eventsController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _eventsController.stream;
    } catch (e) {
      debugPrint('Error in getEventsStream: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get real-time updates of events filtered by petId.
  Stream<List<Event>> getEventsByPetId(String petId) {
    try {
      return _firestore
          .collection('events')
          .where('petId', isEqualTo: petId)
          .snapshots()
          .map((snapshot) {
        final events = snapshot.docs.map((doc) {
          final event = Event.fromDocument(doc);
          _cache[event.id] = event;
          return event;
        }).toList();
        return events;
      });
    } catch (e) {
      debugPrint('Error in getEventsByPetId: $e');
      return Stream.error(e);
    }
  }

  /// Fetches a specific event by ID with caching.
  Stream<Event?> getEventByIdStream(String eventId) {
    return Stream.fromFuture(getEventById(eventId));
  }

  Future<Event?> getEventById(String eventId) async {
    if (_cache.containsKey(eventId)) {
      return _cache[eventId];
    }

    try {
      final docSnapshot =
          await _firestore.collection('events').doc(eventId).get();

      if (docSnapshot.exists) {
        final event = Event.fromDocument(docSnapshot);
        _cache[eventId] = event;
        return event;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching event by ID: $e');
      return null;
    }
  }

  /// Adds a new event to Firestore.
  Future<void> addEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).set(event.toMap());
      _cache[event.id] = event;
    } catch (e) {
      debugPrint('Error adding event: $e');
    }
  }

  /// Updates an existing event in Firestore.
  Future<void> updateEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).update(event.toMap());
      _cache[event.id] = event;
    } catch (e) {
      debugPrint('Error updating event: $e');
    }
  }

  /// Deletes an event from Firestore by ID.
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      _cache.remove(eventId);
    } catch (e) {
      debugPrint('Error deleting event: $e');
    }
  }

  /// Fetches events associated with a specific pillId.
  Future<List<Event>> getEventsByPillId(String pillId) async {
    try {
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
    } catch (e) {
      debugPrint('Error fetching events by pillId: $e');
      return [];
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _eventsController.close();
  }
}
