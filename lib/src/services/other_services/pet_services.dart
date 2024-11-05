import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

class PetService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _petsController = StreamController<List<Pet>>.broadcast();

  // Stream to get pets owned by the current user
  Stream<List<Pet>> getPets() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore.collection('pets').snapshots().listen((snapshot) {
      _petsController
          .add(snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList());
    });

    // Stream to get pets shared with the user
    final sharedPetsStream = _firestore
        .collection('pets')
        .where('sharedWithIds', arrayContains: _currentUser.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList());

    // Combine both streams
    return sharedPetsStream;
  }

  // Stream for a specific pet by ID
  Stream<Pet?> getPetByIdStream(String petId) {
    return Stream.fromFuture(getPetById(petId));
  }

  Future<Pet?> getPetById(String petId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore.collection('pets').doc(petId).get();

    return docSnapshot.exists ? Pet.fromDocument(docSnapshot) : null;
  }

  Future<void> addPet(Pet pet) async {
    await _firestore.collection('pets').doc(pet.id).set(pet.toMap());
  }

  Future<void> updatePet(Pet pet) async {
    await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
  }

  Future<void> deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  Future<List<Pet>> getPetsByUserId(String userId) async {
    final snapshot = await _firestore.collection('pets').get();
    return snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
  }

  Future<List<Pet>> getPetsFriendFuture(String uid) async {
    final querySnapshot = await _firestore.collection('pets').get();

    return querySnapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
  }

  void dispose() {
    _petsController.close();
  }
}
