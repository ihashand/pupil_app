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
    final imageSize = screenSize.width * 0.49;

    return Column(
      children: [
        Image.asset(
          assetPath,
          height: imageSize,
          width: imageSize,
        ),
      ],
    );
  }
}
