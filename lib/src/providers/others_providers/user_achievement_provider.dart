import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/pet_achievement.dart';
import 'package:pet_diary/src/services/other_services/pet_achievement_service.dart';

final petAchievementServiceProvider =
    Provider((ref) => PetAchievementService());

final petAchievementsProvider =
    FutureProvider.family<List<PetAchievement>, String>((ref, petId) async {
  final service = ref.read(petAchievementServiceProvider);
  return await service.getPetAchievements(petId);
});
