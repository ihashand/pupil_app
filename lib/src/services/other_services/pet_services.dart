import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:rxdart/rxdart.dart';

class PetService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _petsController = StreamController<List<Pet>>.broadcast();

  Stream<List<Pet>> getPets() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    // Stream to get the user's pets
    final userPetsStream = _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList());

    // Stream to get pets shared with the user
    final sharedPetsStream = _firestore
        .collection('app_users')
        .collection('pets')
        .where('sharedWith', arrayContains: _currentUser.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList());

    // Combine both streams
    return Rx.combineLatest2(
      userPetsStream,
      sharedPetsStream,
      (List<Pet> userPets, List<Pet> sharedPets) {
        return [...userPets, ...sharedPets];
      },
    ).asBroadcastStream();
  }

  Stream<Pet?> getPetByIdStream(String petId) {
    return Stream.fromFuture(getPetById(petId));
  }

  Future<Pet?> getPetById(String petId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .get();

    return docSnapshot.exists ? Pet.fromDocument(docSnapshot) : null;
  }

  Future<void> addPet(Pet pet) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(pet.id)
        .set(pet.toMap());
  }

  Future<void> updatePet(Pet pet) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(pet.id)
        .update(pet.toMap());
  }

  Future<void> deletePet(String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .delete();
  }

  Future<List<Pet>> getPetsByUserId(String userId) async {
    final snapshot = await _firestore
        .collection('app_users')
        .doc(userId)
        .collection('pets')
        .get();
    return snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
  }

  Stream<List<Pet>> getPetsFriendStream(String uid) {
    final petsStream = _firestore
        .collection('app_users')
        .doc(uid)
        .collection('pets')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList());

    return petsStream;
  }

  Future<List<Pet>> getPetsFriendFuture(String uid) async {
    final querySnapshot = await _firestore
        .collection('app_users')
        .doc(uid)
        .collection('pets')
        .get();

    // Zwracamy listę zwierząt z dokumentów
    return querySnapshot.docs.map((doc) => Pet.fromDocument(doc)).toList();
  }

  void dispose() {
    _petsController.close();
  }
}
