import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/pet_repository.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import '../models/pill_model.dart';
import '../models/weight_model.dart'; // Import your Pet model

final petRepositoryProvider = FutureProvider<PetRepository>((_) async {
  return await PetRepository.create();
});

final petIdProvider = StateProvider<String>((ref) {
  return '1'; // Initial value for pet id
});

final petNameProvider = Provider<TextEditingController>((ref) {
  return TextEditingController(); // Initial value for pet name
});

final petImageProvider = StateProvider<String>((ref) {
  return 'assets/images/dog_avatar_01.png'; // Initial value for pet image
});

final petAgeProvider = Provider<TextEditingController>((ref) {
  return TextEditingController(); // Initial value for pet name
});

final petGenderProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final petColorProvider = Provider<TextEditingController>((ref) {
  return TextEditingController(); // Initial value for pet name
});

final petWeightsProvider = StateProvider<List<Weight>>((ref) {
  return []; // Initial value for pet weights
});

final petPillsProvider = StateProvider<List<Pill>>((ref) {
  return []; // Initial value for pet pills
});

final petEventsProvider = StateProvider<List<Event>>((ref) {
  return []; // Initial value for pet events
});

// Provider for the Pet model
final petProvider = Provider<Pet>((ref) {
  // Access each individual provider to build the Pet object
  return Pet(
    id: ref.watch(petIdProvider),
    name: ref.watch(petNameProvider).text,
    image: ref.watch(petImageProvider),
    age: ref.watch(petAgeProvider).text,
    gender: ref.watch(petGenderProvider).text,
    color: ref.watch(petColorProvider).text,
    pills: ref.watch(petPillsProvider),
    events: ref.watch(petEventsProvider),
    userId: FirebaseAuth.instance.currentUser?.uid ?? "",
  );
});
