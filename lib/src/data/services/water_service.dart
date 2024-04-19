import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/water_model.dart';

class WaterService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _waterController = StreamController<List<Water>>.broadcast();

  Stream<List<Water>> getWatersStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('water')
        .snapshots()
        .listen((snapshot) {
      _waterController
          .add(snapshot.docs.map((doc) => Water.fromDocument(doc)).toList());
    });

    return _waterController.stream;
  }

  Stream<Water?> getWaterByIdStream(String waterId) {
    return Stream.fromFuture(getWaterById(waterId));
  }

  Future<Water?> getWaterById(String waterId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('water')
        .doc(waterId)
        .get();

    return docSnapshot.exists ? Water.fromDocument(docSnapshot) : null;
  }

  Future<void> addWater(Water water) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('water')
        .doc(water.id)
        .set(water.toMap());
  }

  Future<void> updateWater(Water water) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('water')
        .doc(water.id)
        .update(water.toMap());
  }

  Future<void> deleteWater(String waterId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('water')
        .doc(waterId)
        .delete();
  }

  void dispose() {
    _waterController.close();
  }
}
