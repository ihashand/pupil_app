import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/others/global_walk_model.dart';

class GlobalWalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for managing global walks stream
  final StreamController<List<GlobalWalkModel>> _walksController =
      StreamController<List<GlobalWalkModel>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Add a new global walk to Firestore.
  Future<void> addGlobalWalk(GlobalWalkModel globalWalk) async {
    try {
      if (_currentUser == null) throw Exception('User not logged in');
      await _firestore
          .collection('global_walks')
          .doc(globalWalk.id)
          .set(globalWalk.toMap());
    } catch (e) {
      debugPrint('Error adding global walk: $e');
      throw Exception('Failed to add global walk');
    }
  }

  /// Fetch a global walk by ID.
  Future<GlobalWalkModel?> getGlobalWalkById(String walkId) async {
    try {
      if (_currentUser == null) throw Exception('User not logged in');
      final docSnapshot =
          await _firestore.collection('global_walks').doc(walkId).get();

      if (docSnapshot.exists) {
        return GlobalWalkModel.fromDocument(docSnapshot);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching global walk by ID: $e');
      throw Exception('Failed to fetch global walk');
    }
  }

  /// Update an existing global walk.
  Future<void> updateGlobalWalk(GlobalWalkModel globalWalk) async {
    try {
      if (_currentUser == null) throw Exception('User not logged in');
      await _firestore
          .collection('global_walks')
          .doc(globalWalk.id)
          .update(globalWalk.toMap());
    } catch (e) {
      debugPrint('Error updating global walk: $e');
      throw Exception('Failed to update global walk');
    }
  }

  /// Delete a global walk by ID.
  Future<void> deleteGlobalWalk(String walkId) async {
    try {
      if (_currentUser == null) throw Exception('User not logged in');
      await _firestore.collection('global_walks').doc(walkId).delete();
    } catch (e) {
      debugPrint('Error deleting global walk: $e');
      throw Exception('Failed to delete global walk');
    }
  }

  /// Stream of global walks from Firestore.
  Stream<List<GlobalWalkModel>> getGlobalWalksStream() {
    try {
      if (_currentUser == null) {
        return Stream.value([]);
      }

      final subscription =
          _firestore.collection('global_walks').snapshots().listen(
        (snapshot) {
          final walks = snapshot.docs
              .map((doc) => GlobalWalkModel.fromDocument(doc))
              .toList();
          _walksController.add(walks);
        },
        onError: (error) {
          debugPrint('Error streaming global walks: $error');
          _walksController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _walksController.stream;
    } catch (e) {
      debugPrint('Error in getGlobalWalksStream: $e');
      return Stream.error(e);
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _walksController.close();
  }
}
