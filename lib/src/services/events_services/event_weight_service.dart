import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';

class EventWeightService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _weightsController =
      StreamController<List<EventWeightModel>>.broadcast();

  Stream<List<EventWeightModel>> getWeightsStream(String? petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_weights')
        .snapshots()
        .listen((snapshot) {
      _weightsController.add(snapshot.docs
          .map((doc) => EventWeightModel.fromDocument(doc))
          .toList());
    });

    return _weightsController.stream;
  }

  Stream<EventWeightModel?> getWeightByIdStream(
      String weightId, String? petId) {
    return Stream.fromFuture(getWeightById(weightId, petId));
  }

  Future<EventWeightModel?> getWeightById(
      String weightId, String? petId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_weights')
        .doc(weightId)
        .get();

    return docSnapshot.exists
        ? EventWeightModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addWeight(EventWeightModel weight, String? petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_weights')
        .doc(weight.id)
        .set(weight.toMap());
  }

  Future<void> updateWeight(EventWeightModel weight, String? petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_weights')
        .doc(weight.id)
        .update(weight.toMap());
  }

  Future<void> deleteWeight(String weightId, String? petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_weights')
        .doc(weightId)
        .delete();
  }

  Future<EventWeightModel?> getLastKnownWeight(String? petId) async {
    if (_currentUser == null || petId == null) return null;

    final querySnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
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
