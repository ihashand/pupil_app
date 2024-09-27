import 'package:flutter/material.dart';

class AchievementWidget extends StatelessWidget {
  final String achievementName;
  final int currentSteps;
  final int totalSteps;
  final String assetPath;

  const AchievementWidget({
    super.key,
    required this.achievementName,
    required this.currentSteps,
    required this.totalSteps,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.width * 0.4;

    return Column(
      children: [
        Image.asset(
          assetPath,
          height: imageSize,
          width: imageSize,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            totalSteps.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        Text(
          'S T E P S',
          style: TextStyle(
            fontSize: 9,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            achievementName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }
}
