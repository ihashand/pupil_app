import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/walk_model.dart';

class WalkService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _walksController = StreamController<List<WalkModel>>.broadcast();

  Stream<List<WalkModel>> getWalks() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('walks')
        .snapshots()
        .listen((snapshot) {
      _walksController.add(
          snapshot.docs.map((doc) => WalkModel.fromDocument(doc)).toList());
    });

    return _walksController.stream;
  }

  Stream<WalkModel?> getWalkByIdStream(String walkId) {
    return Stream.fromFuture(getWalkById(walkId));
  }

  Future<WalkModel?> getWalkById(String walkId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('walks')
        .doc(walkId)
        .get();

    return docSnapshot.exists ? WalkModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addWalk(WalkModel walk) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walk.id)
        .set(walk.toMap());
  }

  Future<void> updateWalk(WalkModel walk) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walk.id)
        .update(walk.toMap());
  }

  Future<void> deleteWalk(String walkId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walkId)
        .delete();
  }

  void dispose() {
    _walksController.close();
  }
}
