import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_diary/src/models/others/app_user_model.dart';

class AppUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _usersController = StreamController<List<AppUserModel>>.broadcast();

  Stream<List<AppUserModel>> getAppUsersStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore.collection('app_users').snapshots().listen((snapshot) {
      _usersController.add(
          snapshot.docs.map((doc) => AppUserModel.fromDocument(doc)).toList());
    });

    return _usersController.stream;
  }

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
      if (kDebugMode) {
        print('Error fetching user by ID: $e');
      }
      return null;
    }
  }

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
      if (kDebugMode) {
        print('Error fetching user by email: $e');
      }
      return null;
    }
  }

  Future<void> addAppUser(AppUserModel appUser) async {
    await _firestore
        .collection('app_users')
        .doc(appUser.id)
        .set(appUser.toMap());
  }

  Future<void> deleteAppUser(String appUserId) async {
    await _firestore.collection('app_users').doc(appUserId).delete();
  }

  Future<void> updateAppUser(AppUserModel user) async {
    await _firestore.collection('app_users').doc(user.id).update(user.toMap());
  }

  void dispose() {
    _usersController.close();
  }
}
