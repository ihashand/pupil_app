import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/pet_repository.dart';
import 'package:pet_diary/src/models/pet_model.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) => PetRepository());

class PetProvider extends StateNotifier<List<Pet>?> {
  PetProvider(this.ref) : super(null) {
    repo = ref.read(petRepositoryProvider);
    fetchPet();
  }
  late PetRepository? repo;
  final StateNotifierProviderRef ref;

  void fetchPet() {
    state = repo!.getPets();
  }

  void addPet(Pet pet) {
    state = repo!.addPet(pet);
  }

  void removePet(String id) {
    state = repo!.deletePet(id);
  }

  void updatePet(Pet pet) {
    state = repo!.updatePet(pet);
  }
}

final petNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final ageControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});
