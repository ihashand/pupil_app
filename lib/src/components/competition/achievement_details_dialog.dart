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
          padding: const EdgeInsets.only(top: 15.0, bottom: 5),
          child: Text(
            'A C H I E V E M E N T',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
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
          padding: const EdgeInsets.only(bottom: 5.0, top: 20),
          child: Text(
            achievementName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          '$totalSteps',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 18,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            "S T E P S",
            style: TextStyle(
                fontSize: 9, color: Theme.of(context).primaryColorDark),
          ),
        ),
      ],
    );
  }
}
