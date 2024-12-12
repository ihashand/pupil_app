import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/local_user_model.dart';

class LocalUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for managing local users stream
  final StreamController<List<LocalUser>> _localUserController =
      StreamController<List<LocalUser>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Get a stream of local users.
  Stream<List<LocalUser>> getLocalUsersStream() {
    try {
      if (_currentUser == null) {
        return Stream.value([]);
      }

      final subscription =
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

      _subscriptions.add(subscription);
      return _localUserController.stream;
    } catch (e) {
      debugPrint('Error in getLocalUsersStream: $e');
      return Stream.error(e);
    }
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

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _localUserController.close();
  }
}
