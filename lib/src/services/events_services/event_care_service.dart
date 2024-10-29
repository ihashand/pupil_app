import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';

class EventCareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _caresController = StreamController<List<EventCareModel>>.broadcast();

  Stream<List<EventCareModel>> getCaresStream() {
    _firestore.collection('event_cares').snapshots().listen((snapshot) {
      _caresController.add(
        snapshot.docs.map((doc) => EventCareModel.fromDocument(doc)).toList(),
      );
    });

    return _caresController.stream;
  }

  Future<void> addCare(EventCareModel care) async {
    await _firestore.collection('event_cares').doc(care.id).set(care.toMap());
  }

  Future<void> deleteCare(String careId) async {
    await _firestore.collection('event_cares').doc(careId).delete();
  }

  void dispose() {
    _caresController.close();
  }
}
