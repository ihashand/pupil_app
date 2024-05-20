import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/walk_model.dart';

class WalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final StreamController<List<Walk>> _walksController =
      StreamController<List<Walk>>.broadcast();

  WalkService() {
    _initWalksStream();
  }

  void _initWalksStream() {
    if (_currentUser != null) {
      _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('walks')
          .orderBy('dateTime', descending: true) // Sortowanie dokumentów
          .snapshots()
          .listen((snapshot) {
        final walks =
            snapshot.docs.map((doc) => Walk.fromDocument(doc)).toList();
        _walksController.add(walks);
      });
    }
  }

  Stream<List<Walk>> getWalksStream() => _walksController.stream;

  Future<Walk?> getWalkById(String walkId) async {
    if (_currentUser == null) return null;

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walkId)
        .get();

    return docSnapshot.exists ? Walk.fromDocument(docSnapshot) : null;
  }

  Future<void> addWalk(Walk walk) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walk.id)
        .set(walk.toMap());
  }

  Future<void> updateWalk(Walk walk) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walk.id)
        .update(walk.toMap());
  }

  Future<void> deleteWalk(String walkId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('walks')
        .doc(walkId)
        .delete();
  }

  void dispose() {
    _walksController.close();
  }
}
