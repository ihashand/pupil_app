import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/local_user_model.dart';

class LocalUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _localUsersSubscription;
  final StreamController<List<LocalUser>> _localUserController =
      StreamController<List<LocalUser>>.broadcast();

  /// Get a stream of local users.
  Stream<List<LocalUser>> getLocalUsersStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _localUsersSubscription =
        _firestore.collection('localUsers').snapshots().listen(
      (snapshot) {
        final localUsers =
            snapshot.docs.map((doc) => LocalUser.fromDocument(doc)).toList();
        _localUserController.add(localUsers);
      },
      onError: (error) {
        debugPrint('Error fetching local users stream: $error');
        _localUserController.addError(error);
      },
    );

    return _localUserController.stream;
  }

  /// Get a specific local user by ID.
  Future<LocalUser?> getLocalUserById(String localUserId) async {
    try {
      if (_currentUser == null) throw Exception('User not logged in');
      final docSnapshot =
          await _firestore.collection('localUsers').doc(localUserId).get();

      return docSnapshot.exists ? LocalUser.fromDocument(docSnapshot) : null;
    } catch (e) {
      debugPrint('Error fetching local user by ID: $e');
      throw Exception('Failed to fetch local user');
    }
  }

  /// Add a new local user to Firestore.
  Future<void> addLocalUser(LocalUser localUser) async {
    try {
      await _firestore
          .collection('localUsers')
          .doc(localUser.id)
          .set(localUser.toMap());
    } catch (e) {
      debugPrint('Error adding local user: $e');
      throw Exception('Failed to add local user');
    }
  }

  /// Update an existing local user.
  Future<void> updateLocalUser(LocalUser localUser) async {
    try {
      await _firestore
          .collection('localUsers')
          .doc(localUser.id)
          .update(localUser.toMap());
    } catch (e) {
      debugPrint('Error updating local user: $e');
      throw Exception('Failed to update local user');
    }
  }

  /// Delete a local user by ID.
  Future<void> deleteLocalUser(String localUserId) async {
    try {
      await _firestore.collection('localUsers').doc(localUserId).delete();
    } catch (e) {
      debugPrint('Error deleting local user: $e');
      throw Exception('Failed to delete local user');
    }
  }

  /// Cancel active subscriptions and clean up resources.
  void cancelSubscription() {
    _localUsersSubscription?.cancel();
  }

  /// Dispose the service by closing the stream controller.
  void dispose() {
    cancelSubscription();
    _localUserController.close();
  }
}
