import 'package:flutter/material.dart';

class AchievementDetailsDialog extends StatelessWidget {
  final String achievementName;
  final int currentSteps;
  final int totalSteps;
  final String assetPath;

  const AchievementDetailsDialog({
    super.key,
    required this.achievementName,
    required this.currentSteps,
    required this.totalSteps,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.width * 0.6;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Achievement',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(thickness: 2),
          Image.asset(
            assetPath,
            height: imageSize,
            width: imageSize,
          ),
          const SizedBox(height: 20),
          Text(
            achievementName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '🚶 Steps: $currentSteps / $totalSteps',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '⏳ Remaining: ${totalSteps - currentSteps}',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
