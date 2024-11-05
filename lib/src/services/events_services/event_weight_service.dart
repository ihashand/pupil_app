import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventWeightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<EventWeightModel>? _cachedWeights;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  Future<List<EventWeightModel>> getWeightsOnce(String petId) async {
    if (_cachedWeights != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWeights!;
    }

    final querySnapshot = await _firestore
        .collection('event_weights')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser?.uid)
        .get();

    _cachedWeights = querySnapshot.docs
        .map((doc) => EventWeightModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedWeights!;
  }

  Stream<List<EventWeightModel>> getWeightsStream(String petId) {
    return _firestore
        .collection('event_weights')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventWeightModel.fromDocument(doc))
            .toList());
  }

  Future<void> addWeight(EventWeightModel weight) async {
    await _firestore
        .collection('event_weights')
        .doc(weight.id)
        .set(weight.toMap());
    _cachedWeights = null;
  }

  Future<void> updateWeight(EventWeightModel weight) async {
    await _firestore
        .collection('event_weights')
        .doc(weight.id)
        .update(weight.toMap());
    _cachedWeights = null;
  }

  Future<void> deleteWeight(String weightId) async {
    await _firestore.collection('event_weights').doc(weightId).delete();
    _cachedWeights = null;
  }

  // Metoda zwracająca ostatnią znaną wagę dla konkretnego zwierzęcia (petId)
  Future<EventWeightModel?> getLastKnownWeight(String petId) async {
    final querySnapshot = await _firestore
        .collection('event_weights')
        .where('petId', isEqualTo: petId)
        .orderBy('dateTime', descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return EventWeightModel.fromDocument(querySnapshot.docs.first);
    }
    return null;
  }
}
