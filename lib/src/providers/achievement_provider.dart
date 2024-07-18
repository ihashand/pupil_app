import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/achievement.dart';
import 'package:pet_diary/src/services/achievement_service.dart';

final achievementServiceProvider = Provider((ref) => AchievementService());

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.read(achievementServiceProvider);
  return await service.getAllAchievements();
});
