import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/user_achievement.dart';
import 'package:pet_diary/services/other_services/user_achievement_service.dart';

final userAchievementServiceProvider =
    Provider((ref) => UserAchievementService());

final userAchievementsProvider =
    FutureProvider<List<UserAchievement>>((ref) async {
  final service = ref.read(userAchievementServiceProvider);
  return await service.getUserAchievements();
});
