import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/competition/achievement_details_dialog.dart';
import 'package:pet_diary/src/components/competition/achievement_widget.dart';
import 'package:pet_diary/src/providers/achievements_providers/achievements_provider.dart';

class AchievementSection extends ConsumerWidget {
  const AchievementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonalAchievementAsyncValue =
        ref.watch(seasonalAchievementProvider);

    return seasonalAchievementAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (achievement) {
        return GestureDetector(
          onTap: () {
            _showAchievementDetails(
              context,
              achievement.name,
              45000,
              achievement.stepsRequired,
              achievement.avatarUrl,
            );
          },
          child: AchievementWidget(
            achievementName: achievement.name,
            currentSteps: 45000,
            totalSteps: achievement.stepsRequired,
            assetPath: achievement.avatarUrl,
          ),
        );
      },
    );
  }

  void _showAchievementDetails(BuildContext context, String achievementName,
      int currentSteps, int totalSteps, String assetPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: AchievementDetailsDialog(
            achievementName: achievementName,
            currentSteps: currentSteps,
            totalSteps: totalSteps,
            assetPath: assetPath,
          ),
        );
      },
    );
  }
}
