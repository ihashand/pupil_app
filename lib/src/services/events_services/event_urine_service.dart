import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';

class EventUrineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _urineEventsController =
      StreamController<List<EventUrineModel>>.broadcast();

  Stream<List<EventUrineModel>> getUrineEventsStream(String petId) {
    _firestore.collection('event_urines').snapshots().listen((snapshot) {
      _urineEventsController.add(snapshot.docs
          .map((doc) => EventUrineModel.fromDocument(doc))
          .toList());
    });

    return _urineEventsController.stream;
  }

  Future<void> addUrineEvent(EventUrineModel event) async {
    await _firestore
        .collection('event_urines')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteUrineEvent(String eventId) async {
    await _firestore.collection('event_urines').doc(eventId).delete();
  }

  void dispose() {
    _urineEventsController.close();
  }
}
