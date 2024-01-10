import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/pet_repository.dart';

final petRepositoryProvider = FutureProvider<PetRepository>((_) async {
  return await PetRepository.create();
});

final petNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final ageControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final selectedAvatarProvider = StateProvider<String>((ref) {
  return 'assets/images/dog_avatar_01.png';
});
