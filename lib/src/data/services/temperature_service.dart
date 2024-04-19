import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/temperature_model.dart';

class TemperatureService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _temperatureController =
      StreamController<List<Temperature>>.broadcast();

  Stream<List<Temperature>> getTemperatureStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('temperatures')
        .snapshots()
        .listen((snapshot) {
      _temperatureController.add(
          snapshot.docs.map((doc) => Temperature.fromDocument(doc)).toList());
    });

    return _temperatureController.stream;
  }

  Future<Temperature?> getTemperatureById(String temperatureId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('temperatures')
        .doc(temperatureId)
        .get();

    return docSnapshot.exists ? Temperature.fromDocument(docSnapshot) : null;
  }

  Future<void> addTemperature(Temperature temperature) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('temperatures')
        .doc(temperature.id)
        .set(temperature.toMap());
  }

  Future<void> updateTemperature(Temperature temperature) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('temperatures')
        .doc(temperature.id)
        .update(temperature.toMap());
  }

  Future<void> deleteTemperature(String temperatureId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('temperatures')
        .doc(temperatureId)
        .delete();
  }

  void dispose() {
    _temperatureController.close();
  }
}
