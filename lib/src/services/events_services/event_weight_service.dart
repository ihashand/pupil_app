import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';

class EventWeightService {
  final _firestore = FirebaseFirestore.instance;

  final _weightsController =
      StreamController<List<EventWeightModel>>.broadcast();

  Stream<List<EventWeightModel>> getWeightsStream(String? petId) {
    _firestore.collection('event_weights').snapshots().listen((snapshot) {
      _weightsController.add(snapshot.docs
          .map((doc) => EventWeightModel.fromDocument(doc))
          .toList());
    });

    return _weightsController.stream;
  }

  Stream<EventWeightModel?> getWeightByIdStream(String weightId) {
    return Stream.fromFuture(getWeightById(weightId));
  }

  Future<EventWeightModel?> getWeightById(
    String weightId,
  ) async {
    final docSnapshot =
        await _firestore.collection('event_weights').doc(weightId).get();

    return docSnapshot.exists
        ? EventWeightModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addWeight(
    EventWeightModel weight,
  ) async {
    await _firestore
        .collection('event_weights')
        .doc(weight.id)
        .set(weight.toMap());
  }

  Future<void> updateWeight(
    EventWeightModel weight,
  ) async {
    await _firestore
        .collection('event_weights')
        .doc(weight.id)
        .update(weight.toMap());
  }

  Future<void> deleteWeight(
    String weightId,
  ) async {
    await _firestore.collection('event_weights').doc(weightId).delete();
  }

  Future<EventWeightModel?> getLastKnownWeight() async {
    final querySnapshot = await _firestore
        .collection('event_weights')
        .orderBy('dateTime', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return EventWeightModel.fromDocument(querySnapshot.docs.first);
    }
    return null;
  }

  void dispose() {
    _weightsController.close();
  }
}
