import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_weight_model.dart';

class EventWeightService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _weightsController =
      StreamController<List<EventWeightModel>>.broadcast();

  Stream<List<EventWeightModel>> getWeightsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_weights')
        .snapshots()
        .listen((snapshot) {
      _weightsController.add(snapshot.docs
          .map((doc) => EventWeightModel.fromDocument(doc))
          .toList());
    });

    return _weightsController.stream;
  }

  Stream<EventWeightModel?> getWeightByIdStream(String weightId) {
    return Stream.fromFuture(getWeightById(weightId));
  }

  Future<EventWeightModel?> getWeightById(String weightId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_weights')
        .doc(weightId)
        .get();

    return docSnapshot.exists
        ? EventWeightModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addWeight(EventWeightModel weight) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_weights')
        .doc(weight.id)
        .set(weight.toMap());
  }

  Future<void> updateWeight(EventWeightModel weight) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_weights')
        .doc(weight.id)
        .update(weight.toMap());
  }

  Future<void> deleteWeight(String weightId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_weights')
        .doc(weightId)
        .delete();
  }

  void dispose() {
    _weightsController.close();
  }
}
