import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_temperature_model.dart';

class EventTemperatureService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _temperatureController =
      StreamController<List<EventTemperatureModel>>.broadcast();

  Stream<List<EventTemperatureModel>> getTemperatureStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_temperatures')
        .snapshots()
        .listen((snapshot) {
      _temperatureController.add(snapshot.docs
          .map((doc) => EventTemperatureModel.fromDocument(doc))
          .toList());
    });

    return _temperatureController.stream;
  }

  Future<EventTemperatureModel?> getTemperatureById(
      String temperatureId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_temperatures')
        .doc(temperatureId)
        .get();

    return docSnapshot.exists
        ? EventTemperatureModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addTemperature(EventTemperatureModel temperature) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_temperatures')
        .doc(temperature.id)
        .set(temperature.toMap());
  }

  Future<void> updateTemperature(EventTemperatureModel temperature) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_temperatures')
        .doc(temperature.id)
        .update(temperature.toMap());
  }

  Future<void> deleteTemperature(String temperatureId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_temperatures')
        .doc(temperatureId)
        .delete();
  }

  void dispose() {
    _temperatureController.close();
  }
}
