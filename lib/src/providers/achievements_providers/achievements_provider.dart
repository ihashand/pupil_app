import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/services/achievements_services/achievement_service.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

final seasonalAchievementProvider = FutureProvider<Achievement>((ref) async {
  final achievementService = ref.watch(achievementServiceProvider);
  return achievementService.getSeasonalAchievement();
});
