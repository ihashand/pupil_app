import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_temperature_model.dart';

class EventTemperatureService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);
  List<EventTemperatureModel>? _cachedTemperatures;
  DateTime? _lastFetchTime;
  final _temperatureController =
      StreamController<List<EventTemperatureModel>>.broadcast();

  Stream<List<EventTemperatureModel>> getTemperatureStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    _firestore
        .collection('event_temperatures')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      _temperatureController.add(snapshot.docs
          .map((doc) => EventTemperatureModel.fromDocument(doc))
          .toList());
    });

    return _temperatureController.stream;
  }

  Future<List<EventTemperatureModel>> getTemperaturesOnce() async {
    if (_cachedTemperatures != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedTemperatures!;
    }

    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('event_temperatures')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();

    _cachedTemperatures = querySnapshot.docs
        .map((doc) => EventTemperatureModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedTemperatures!;
  }

  Future<EventTemperatureModel?> getTemperatureById(
      String temperatureId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('event_temperatures')
        .doc(temperatureId)
        .get();

    return docSnapshot.exists
        ? EventTemperatureModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addTemperature(EventTemperatureModel temperature) async {
    await _firestore
        .collection('event_temperatures')
        .doc(temperature.id)
        .set(temperature.toMap());
    _cachedTemperatures = null;
  }

  Future<void> updateTemperature(EventTemperatureModel temperature) async {
    await _firestore
        .collection('event_temperatures')
        .doc(temperature.id)
        .update(temperature.toMap());
    _cachedTemperatures = null;
  }

  Future<void> deleteTemperature(String temperatureId) async {
    await _firestore
        .collection('event_temperatures')
        .doc(temperatureId)
        .delete();
    _cachedTemperatures = null;
  }

  void dispose() {
    _temperatureController.close();
  }
}
