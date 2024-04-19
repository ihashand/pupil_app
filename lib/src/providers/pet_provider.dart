import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/pet_services.dart';

final petServiceProvider = Provider((ref) {
  return PetService();
});
