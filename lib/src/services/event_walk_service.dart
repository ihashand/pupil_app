import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';

class EventWalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final StreamController<List<EventWalkModel>> _walksController =
      StreamController<List<EventWalkModel>>.broadcast();

  EventWalkService() {
    _initWalksStream();
  }

  void _initWalksStream() {
    if (_currentUser != null) {
      _firestore
          .collection('app_users')
          .doc(_currentUser.uid)
          .collection('event_walks')
          .orderBy('dateTime', descending: true)
          .snapshots()
          .listen((snapshot) {
        final walks = snapshot.docs
            .map((doc) => EventWalkModel.fromDocument(doc))
            .toList();
        _walksController.add(walks);
      });
    }
  }

  Stream<List<EventWalkModel>> getWalksStream() => _walksController.stream;

  Future<EventWalkModel?> getWalkById(String walkId) async {
    if (_currentUser == null) return null;

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walkId)
        .get();

    return docSnapshot.exists ? EventWalkModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addWalk(EventWalkModel walk) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walk.id)
        .set(walk.toMap());
  }

  Future<void> updateWalk(EventWalkModel walk) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walk.id)
        .update(walk.toMap());
  }

  Future<void> deleteWalk(String walkId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('event_walks')
        .doc(walkId)
        .delete();
  }

  void dispose() {
    _walksController.close();
  }
}
