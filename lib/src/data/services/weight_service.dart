import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/weight_model.dart';

class WeightService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _weightsController = StreamController<List<Weight>>.broadcast();

  Stream<List<Weight>> getWeightsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('weights')
        .snapshots()
        .listen((snapshot) {
      _weightsController
          .add(snapshot.docs.map((doc) => Weight.fromDocument(doc)).toList());
    });

    return _weightsController.stream;
  }

  Stream<Weight?> getWeightByIdStream(String weightId) {
    return Stream.fromFuture(getWeightById(weightId));
  }

  Future<Weight?> getWeightById(String weightId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('weights')
        .doc(weightId)
        .get();

    return docSnapshot.exists ? Weight.fromDocument(docSnapshot) : null;
  }

  Future<void> addWeight(Weight weight) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('weights')
        .doc(weight.id)
        .set(weight.toMap());
  }

  Future<void> updateWeight(Weight weight) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('weights')
        .doc(weight.id)
        .update(weight.toMap());
  }

  Future<void> deleteWeight(String weightId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('weights')
        .doc(weightId)
        .delete();
  }

  void dispose() {
    _weightsController.close();
  }
}
