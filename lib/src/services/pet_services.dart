import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class PetService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _petsController = StreamController<List<Pet>>.broadcast();

  Stream<List<Pet>> getPets() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .snapshots()
        .listen((snapshot) {
      _petsController
          .add(snapshot.docs.map((doc) => Pet.fromDocument(doc)).toList());
    });

    return _petsController.stream;
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

  void dispose() {
    _petsController.close();
  }
}
