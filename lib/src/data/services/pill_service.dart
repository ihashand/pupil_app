import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/pill_model.dart';

class PillService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _pillsController = StreamController<List<Pill>>.broadcast();

  Stream<List<Pill>> getPills() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('pills')
        .snapshots()
        .listen((snapshot) {
      _pillsController
          .add(snapshot.docs.map((doc) => Pill.fromDocument(doc)).toList());
    });

    return _pillsController.stream;
  }

  Stream<Pill?> getPillByIdStream(String pillId) {
    return Stream.fromFuture(getPillById(pillId));
  }

  Future<Pill?> getPillById(String pillId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('pills')
        .doc(pillId)
        .get();

    return docSnapshot.exists ? Pill.fromDocument(docSnapshot) : null;
  }

  Future<void> addPill(Pill pill) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pills')
        .doc(pill.id)
        .set(pill.toMap());
  }

  Future<void> updatePill(Pill pill) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pills')
        .doc(pill.id)
        .update(pill.toMap());
  }

  Future<void> deletePill(String pillId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pills')
        .doc(pillId)
        .delete();
  }

  void dispose() {
    _pillsController.close();
  }
}
