import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_diary/src/models/others/app_user_model.dart';

class AppUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting app users stream
  final StreamController<List<AppUserModel>> _usersController =
      StreamController<List<AppUserModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream for fetching all app users.
  Stream<List<AppUserModel>> getAppUsersStream() {
    try {
      if (_currentUser == null) {
        return Stream.value([]);
      }

      final subscription =
          _firestore.collection('app_users').snapshots().listen(
        (snapshot) {
          final users = snapshot.docs
              .map((doc) => AppUserModel.fromDocument(doc))
              .toList();
          _usersController.add(users);
        },
        onError: (error) {
          debugPrint('Error fetching app users stream: $error');
          _usersController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _usersController.stream;
    } catch (e) {
      debugPrint('Error in getAppUsersStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetch a user by ID.
  Future<AppUserModel?> getAppUserById(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('app_users').doc(userId).get();

      if (docSnapshot.exists) {
        return AppUserModel.fromDocument(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
    }
  }

  /// Fetch a user by email.
  Future<AppUserModel?> getAppUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('app_users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AppUserModel.fromDocument(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user by email: $e');
      return null;
    }
  }

  /// Add a new app user.
  Future<void> addAppUser(AppUserModel appUser) async {
    try {
      await _firestore
          .collection('app_users')
          .doc(appUser.id)
          .set(appUser.toMap());
    } catch (e) {
      debugPrint('Error adding app user: $e');
      throw Exception('Failed to add app user');
    }
  }

  /// Delete an app user by ID.
  Future<void> deleteAppUser(String appUserId) async {
    try {
      await _firestore.collection('app_users').doc(appUserId).delete();
    } catch (e) {
      debugPrint('Error deleting app user: $e');
      throw Exception('Failed to delete app user');
    }
  }

  /// Update an app user.
  Future<void> updateAppUser(AppUserModel user) async {
    try {
      await _firestore
          .collection('app_users')
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      debugPrint('Error updating app user: $e');
      throw Exception('Failed to update app user');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _usersController.close();
  }
}
