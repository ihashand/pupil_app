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
    final imageSize = screenSize.width * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            achievementName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        Text(
          'A C H I E V E M E N T',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.surface),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Image.asset(
            assetPath,
            height: imageSize,
            width: imageSize,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            '$totalSteps',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            "S T E P S",
            style: TextStyle(
                fontSize: 11, color: Theme.of(context).primaryColorDark),
          ),
        ),
      ],
    );
  }
}
