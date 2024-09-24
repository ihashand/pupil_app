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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'A C H I E V E M E N T',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.surface),
        Image.asset(
          assetPath,
          height: imageSize,
          width: imageSize,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  achievementName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚶 Steps: $currentSteps / $totalSteps',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '⏳ Remaining: ${totalSteps - currentSteps}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
