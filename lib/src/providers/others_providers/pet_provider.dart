import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/services/other_services/pet_services.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

final petServiceProvider = Provider((ref) {
  return PetService();
});

final petsProvider = StreamProvider<List<Pet>>((ref) {
  return PetService().getPets();
});

final petFriendServiceProvider =
    StreamProvider.family<List<Pet>, String>((ref, id) {
  return PetService().getPetsFriend(id);
});
