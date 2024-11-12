import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final List<Color> gradientColors;
  final MainAxisAlignment verticalAlignment;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.icon,
    this.gradientColors = const [Colors.lightBlue, Colors.lightGreen],
    this.verticalAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: verticalAlignment,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      LinearGradient(colors: gradientColors)
                          .createShader(bounds),
                  child: Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
