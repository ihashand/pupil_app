import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/controller/pets_controller.dart';
import 'package:pet_diary/src/data/repositories/pet_repository.dart';
import 'package:pet_diary/src/models/pet_model.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) => PetRepository());

final petHiveData = StateNotifierProvider<PetHiveController, List<Pet>?>(
    (ref) => PetHiveController(ref));

final petNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final ageControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});
