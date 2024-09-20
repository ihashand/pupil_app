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
        const SizedBox(height: 20),
        Text(
          achievementName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
