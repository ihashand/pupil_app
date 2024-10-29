import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_walk_events_model.dart';

class EventWalkEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _urineEventsController =
      StreamController<List<EventWalkEventsModel>>.broadcast();

  Stream<List<EventWalkEventsModel>> getEventsWalksEventStream() {
    _firestore.collection('event_walks_events').snapshots().listen((snapshot) {
      _urineEventsController.add(snapshot.docs
          .map((doc) => EventWalkEventsModel.fromDocument(doc))
          .toList());
    });

    return _urineEventsController.stream;
  }

  Future<void> addEventsWalkEvent(EventWalkEventsModel event) async {
    await _firestore
        .collection('event_walks_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteEventsWalkEvent(String eventId) async {
    await _firestore.collection('event_walks_events').doc(eventId).delete();
  }

  void dispose() {
    _urineEventsController.close();
  }
}
