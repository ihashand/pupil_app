// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class NutrientNewRecipe extends StatelessWidget {
  const NutrientNewRecipe({
    super.key,
    required this.context,
    required this.label,
    required this.value,
    required this.color,
  });

  final BuildContext context;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    String formattedValue;
    if (label == 'Kcal') {
      formattedValue = value.toStringAsFixed(0);
    } else {
      formattedValue =
          value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formattedValue,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
