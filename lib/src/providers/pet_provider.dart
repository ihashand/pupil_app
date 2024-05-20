import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/pet_services.dart';
import 'package:pet_diary/src/models/pet_model.dart';

final petServiceProvider = Provider((ref) {
  return PetService();
});

final petsProvider = StreamProvider<List<Pet>>((ref) {
  return PetService().getPets();
});
