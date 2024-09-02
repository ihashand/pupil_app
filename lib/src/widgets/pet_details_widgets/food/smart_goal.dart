import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';

void showIntroStep(BuildContext context, WidgetRef ref, String petId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      return _buildBottomSheetContent(
        context,
        title: 'Smart Goal Setup!',
        content:
            'In this setup, we will help you determine the optimal daily caloric intake for your dog. Remember, these values are guidelines, and adjustments might be necessary based on your dog\'s specific needs.',
        onNextPressed: () {
          Navigator.pop(context);
          _showWeightStep(context, ref, petId);
        },
      );
    },
  );
}

Widget _buildBottomSheetContent(
  BuildContext context, {
  required String title,
  required String content,
  required VoidCallback onNextPressed,
  Widget? child,
  String buttonText = 'Next',
}) {
  return Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 16),
          if (child != null) ...[
            Center(child: child),
            const SizedBox(height: 16),
          ],
        ],
      ),
    ),
  );
}

void _showWeightStep(BuildContext context, WidgetRef ref, String petId) {
  final TextEditingController weightController = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      return _buildBottomSheetContent(
        context,
        title: 'Step 1: Enter Your Dog\'s Weight',
        content:
            'Please enter your dog\'s current weight. This information is crucial for calculating the base caloric needs.',
        child: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Weight (kg)',
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColorDark,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
        ),
        onNextPressed: () {
          if (weightController.text.isNotEmpty) {
            Navigator.pop(context);
            _showActivityStep(context, ref, weightController.text, petId);
          } else {
            _showWeightErrorDialog(context);
          }
        },
      );
    },
  );
}

void _showActivityStep(
    BuildContext context, WidgetRef ref, String weight, String petId) {
  String activityLevel = 'Moderate';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      return _buildBottomSheetContent(
        context,
        title: 'Step 2: Select Activity Level',
        content:
            'Choose the activity level that best describes your dog\'s daily routine. This helps us better estimate the energy expenditure.',
        child: DropdownButton<String>(
          value: activityLevel,
          onChanged: (String? newValue) {
            activityLevel = newValue!;
          },
          items: <String>['Low', 'Moderate', 'High']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        onNextPressed: () {
          Navigator.pop(context);
          _showGoalStep(context, ref, weight, activityLevel, petId);
        },
      );
    },
  );
}

void _showGoalStep(BuildContext context, WidgetRef ref, String weight,
    String activityLevel, String petId) {
  String goal = 'Maintain Weight';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      return _buildBottomSheetContent(
        context,
        title: 'Step 3: Set Your Dog\'s Goal',
        content:
            'What is the goal for your dog\'s weight? Do you want them to maintain, lose, or gain weight?',
        child: DropdownButton<String>(
          value: goal,
          onChanged: (String? newValue) {
            goal = newValue!;
          },
          items: <String>['Maintain Weight', 'Lose Weight', 'Gain Weight']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        onNextPressed: () {
          Navigator.pop(context);
          _showSummaryStep(context, ref, weight, activityLevel, goal, petId);
        },
      );
    },
  );
}

void _showSummaryStep(BuildContext context, WidgetRef ref, String weight,
    String activityLevel, String goal, String petId) {
  final double kcalRequirement =
      _calculateKcalRequirement(weight, activityLevel, goal);

  // Calculate kcal for each macronutrient based on the percentages
  final double proteinKcal = kcalRequirement * 0.40; // 40%
  final double fatKcal = kcalRequirement * 0.53; // 53%
  final double carbsKcal = kcalRequirement * 0.07; // 7%

  // Convert kcal to grams
  final double proteinG = proteinKcal / 4; // 4 kcal per gram
  final double fatG = fatKcal / 9; // 9 kcal per gram
  final double carbsG = carbsKcal / 4; // 4 kcal per gram

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      return _buildBottomSheetContent(
        context,
        title: 'Summary of Nutritional Goals',
        content:
            'Based on the information provided, these are the recommended daily nutritional goals for your dog.',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutrientIndicatorTest(
                context, 'Energy', kcalRequirement, 'kcal', Colors.blue),
            _buildNutrientIndicatorTest(
                context, 'Protein', proteinG, 'g', Colors.orange),
            _buildNutrientIndicatorTest(
                context, 'Fat', fatG, 'g', Colors.purple),
            _buildNutrientIndicatorTest(
                context, 'Carbs', carbsG, 'g', Colors.green),
          ],
        ),
        onNextPressed: () {
          _submitGoal(ref, kcalRequirement, proteinG, fatG, carbsG, petId);
          Navigator.pop(context);
        },
        buttonText: 'Finish',
      );
    },
  );
}

double _calculateKcalRequirement(
    String weight, String activityLevel, String goal) {
  final double weightValue = double.tryParse(weight) ?? 0;
  final num metabolicWeight = weightValue == 0 ? 0 : pow(weightValue, 0.75);
  double kcalRequirement = metabolicWeight * 70;

  switch (activityLevel) {
    case 'High':
      kcalRequirement *= 2.0;
      break;
    case 'Moderate':
      kcalRequirement *= 1.6;
      break;
    case 'Low':
      kcalRequirement *= 1.2;
      break;
  }

  switch (goal) {
    case 'Lose Weight':
      kcalRequirement *= 0.8;
      break;
    case 'Gain Weight':
      kcalRequirement *= 1.2;
      break;
  }

  return kcalRequirement;
}

void _submitGoal(WidgetRef ref, double kcal, double protein, double fat,
    double carbs, String petId) {
  final provider = ref.read(eventFoodPetSettingsProvider(petId).notifier);

  provider.updateKcal(kcal);
  provider.updateProteinPercentage(protein);
  provider.updateFatPercentage(fat);
  provider.updateCarbsPercentage(carbs);
}

void _showWeightErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Weight error',
        style: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
      content: Text(
        'Please enter your dog\'s weight to proceed.',
        style: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNutrientIndicatorTest(BuildContext context, String label,
    double value, String unit, Color color) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            children: [
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    ],
  );
}
