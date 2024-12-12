import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for managing pets stream
  final StreamController<List<Pet>> _petsController =
      StreamController<List<Pet>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream of pets for the current user.
  Stream<List<Pet>> getPets() {
    try {
      if (_currentUser == null) {
        return Stream.value([]);
      }

      final subscription = _firestore
          .collection('pets')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen(
        (snapshot) {
          final pets =
              snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
          _petsController.add(pets);
        },
        onError: (error) {
          debugPrint('Error fetching pets stream: $error');
          _petsController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _petsController.stream;
    } catch (e) {
      debugPrint('Error in getPets: $e');
      return Stream.error(e);
    }
  }

  /// Stream a specific pet by its ID.
  Stream<Pet?> getPetByIdStream(String petId) {
    try {
      return _firestore
          .collection('pets')
          .doc(petId)
          .snapshots()
          .map((snapshot) {
        return snapshot.exists ? Pet.fromDocument(snapshot) : null;
      });
    } catch (e) {
      debugPrint('Error in getPetByIdStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetch a specific pet by its ID (one-time).
  Future<Pet?> getPetById(String petId) async {
    try {
      if (_currentUser == null) throw Exception('User not logged in');

      final docSnapshot = await _firestore.collection('pets').doc(petId).get();
      return docSnapshot.exists ? Pet.fromDocument(docSnapshot) : null;
    } catch (e) {
      debugPrint('Error fetching pet by ID: $e');
      throw Exception('Failed to fetch pet by ID');
    }
  }

  /// Add a new pet.
  Future<void> addPet(Pet pet) async {
    try {
      await _firestore.collection('pets').doc(pet.id).set(pet.toMap());
    } catch (e) {
      debugPrint('Error adding pet: $e');
      throw Exception('Failed to add pet');
    }
  }

  /// Update an existing pet.
  Future<void> updatePet(Pet pet) async {
    try {
      await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
    } catch (e) {
      debugPrint('Error updating pet: $e');
      throw Exception('Failed to update pet');
    }
  }

  /// Delete a pet by its ID.
  Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      debugPrint('Error deleting pet: $e');
      throw Exception('Failed to delete pet');
    }
  }

  /// Fetch all pets for a specific user as a one-time operation.
  Future<List<Pet>> getPetsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching pets by user ID: $e');
      throw Exception('Failed to fetch pets by user ID');
    }
  }

  /// Stream all pets owned by a friend.
  Stream<List<Pet>> getPetsFriendStream(String friendId) {
    try {
      return _firestore
          .collection('pets')
          .where('userId', isEqualTo: friendId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
      });
    } catch (e) {
      debugPrint('Error in getPetsFriendStream: $e');
      return Stream.error(e);
    }
  }

  /// Fetch all pets owned by a friend as a one-time operation.
  Future<List<Pet>> getPetsFriendFuture(String friendId) async {
    try {
      final querySnapshot = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: friendId)
          .get();
      return querySnapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching friend\'s pets: $e');
      throw Exception('Failed to fetch friend\'s pets');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _petsController.close();
  }
}
