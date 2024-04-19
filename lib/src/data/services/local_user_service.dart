import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/local_user_model.dart';

class LocalUserService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _localUserController = StreamController<List<LocalUser>>.broadcast();

  Stream<List<LocalUser>> getLocalUsersStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('localUsers')
        .snapshots()
        .listen((snapshot) {
      _localUserController.add(
          snapshot.docs.map((doc) => LocalUser.fromDocument(doc)).toList());
    });

    return _localUserController.stream;
  }

  Future<LocalUser?> getLocalUserById(String localUserId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('localUsers')
        .doc(localUserId)
        .get();

    return docSnapshot.exists ? LocalUser.fromDocument(docSnapshot) : null;
  }

  Future<void> addLocalUser(LocalUser localUser) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('localUsers')
        .doc(localUser.id)
        .set(localUser.toMap());
  }

  Future<void> updateLocalUser(LocalUser localUser) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('localUsers')
        .doc(localUser.id)
        .update(localUser.toMap());
  }

  Future<void> deleteLocalUser(String localUserId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('localUsers')
        .doc(localUserId)
        .delete();
  }

  void dispose() {
    _localUserController.close();
  }
}
