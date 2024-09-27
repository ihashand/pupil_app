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
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            achievementName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        Image.asset(
          assetPath,
          height: imageSize,
          width: imageSize,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            totalSteps.toString(),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        Text(
          'S T E P S',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ],
    );
  }
}
