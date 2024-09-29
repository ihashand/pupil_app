import 'package:cloud_firestore/cloud_firestore.dart';
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

final petStepsProviderFamily =
    FutureProvider.family<int, String>((ref, petId) async {
  final stepsData = await FirebaseFirestore.instance
      .collection('pets')
      .doc(petId)
      .collection('steps')
      .orderBy('date', descending: true)
      .limit(1)
      .get();

  if (stepsData.docs.isNotEmpty) {
    return stepsData.docs.first.get('currentSteps') ?? 0;
  } else {
    return 0;
  }
});
