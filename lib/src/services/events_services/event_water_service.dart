import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';

class EventWaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<EventWaterModel>? _cachedWaterEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  Future<List<EventWaterModel>> getWatersOnce(String petId) async {
    if (_cachedWaterEvents != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWaterEvents!;
    }

    final querySnapshot = await _firestore
        .collection('event_waters')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser?.uid)
        .get();

    _cachedWaterEvents = querySnapshot.docs
        .map((doc) => EventWaterModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedWaterEvents!;
  }

  Stream<List<EventWaterModel>> getWatersStream(String petId) {
    return _firestore
        .collection('event_waters')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventWaterModel.fromDocument(doc))
            .toList());
  }

  Future<EventWaterModel?> getWaterById(String waterId) async {
    final docSnapshot =
        await _firestore.collection('event_waters').doc(waterId).get();

    return docSnapshot.exists
        ? EventWaterModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addWater(EventWaterModel waterEvent) async {
    await _firestore
        .collection('event_waters')
        .doc(waterEvent.id)
        .set(waterEvent.toMap());
    _cachedWaterEvents = null;
  }

  Future<void> updateWater(EventWaterModel waterEvent) async {
    await _firestore
        .collection('event_waters')
        .doc(waterEvent.id)
        .update(waterEvent.toMap());
    _cachedWaterEvents = null;
  }

  Future<void> deleteWater(String waterId) async {
    await _firestore.collection('event_waters').doc(waterId).delete();
    _cachedWaterEvents = null;
  }
}
