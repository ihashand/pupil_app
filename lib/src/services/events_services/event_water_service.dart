import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';

class EventWaterService {
  final _firestore = FirebaseFirestore.instance;

  final _waterController = StreamController<List<EventWaterModel>>.broadcast();

  Stream<List<EventWaterModel>> getWatersStream() {
    _firestore.collection('event_waters').snapshots().listen((snapshot) {
      _waterController.add(snapshot.docs
          .map((doc) => EventWaterModel.fromDocument(doc))
          .toList());
    });

    return _waterController.stream;
  }

  Stream<EventWaterModel?> getWaterByIdStream(String waterId) {
    return Stream.fromFuture(getWaterById(waterId));
  }

  Future<EventWaterModel?> getWaterById(String waterId) async {
    final docSnapshot =
        await _firestore.collection('event_waters').doc(waterId).get();

    return docSnapshot.exists
        ? EventWaterModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addWater(EventWaterModel water) async {
    await _firestore
        .collection('event_waters')
        .doc(water.id)
        .set(water.toMap());
  }

  Future<void> updateWater(EventWaterModel water) async {
    await _firestore
        .collection('event_waters')
        .doc(water.id)
        .update(water.toMap());
  }

  Future<void> deleteWater(String waterId) async {
    await _firestore.collection('event_waters').doc(waterId).delete();
  }

  void dispose() {
    _waterController.close();
  }
}
