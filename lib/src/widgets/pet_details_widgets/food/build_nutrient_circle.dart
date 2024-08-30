import 'package:flutter/material.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/_calculate_fill.dart';

Widget buildNutrientCircle(
    BuildContext context, String label, double consumed, double dailyGoal) {
  double fillPercentage = calculateFill(consumed, dailyGoal);

  Color circleColor;
  switch (label) {
    case 'Fat':
      circleColor = Colors.purple;
      break;
    case 'Carbs':
      circleColor = Colors.green;
      break;
    case 'Protein':
      circleColor = Colors.orange;
      break;
    default:
      circleColor = Colors.blue;
  }

  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 75,
            height: 75,
            child: CircularProgressIndicator(
              value: fillPercentage,
              strokeWidth: 5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(circleColor),
            ),
          ),
          Column(
            children: [
              Text(
                consumed.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(fillPercentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
