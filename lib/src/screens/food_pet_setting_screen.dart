import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/smart_goal.dart';

class FoodPetSettingsScreen extends ConsumerWidget {
  final String petId;

  const FoodPetSettingsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodPetSettingsState = ref.watch(eventFoodPetSettingsProvider(petId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'S E T T I N G S',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: foodPetSettingsState == null
          ? Center(
              child: Text(
                'No settings found for this pet.',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 16,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Daily Nutritional Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2.0, 25, 2.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutrientIndicator(
                                context,
                                'Energy',
                                foodPetSettingsState.dailyKcal,
                                'kcal',
                                Colors.blue,
                                ref),
                            _buildNutrientIndicator(
                                context,
                                'Protein',
                                foodPetSettingsState.proteinPercentage,
                                'g',
                                Colors.orange,
                                ref),
                            _buildNutrientIndicator(
                                context,
                                'Fat',
                                foodPetSettingsState.fatPercentage,
                                'g',
                                Colors.purple,
                                ref),
                            _buildNutrientIndicator(
                                context,
                                'Carbs',
                                foodPetSettingsState.carbsPercentage,
                                'g',
                                Colors.green,
                                ref),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 20, 8.0, 0.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showIntroStep(context, ref, petId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 80.0),
                          ),
                          child: Text(
                            'Smart Goal',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Meals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foodPetSettingsState.mealTypes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, _) {
                                      final controller = TextEditingController(
                                        text: foodPetSettingsState
                                            .mealTypes[index],
                                      );
                                      return TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Meal ${index + 1}',
                                          labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                          ),
                                        ),
                                        controller: controller,
                                        onChanged: (value) {
                                          final updatedMealTypes =
                                              List<String>.from(
                                                  foodPetSettingsState
                                                      .mealTypes);
                                          updatedMealTypes[index] = value;
                                          _updateMealTypes(
                                              ref, updatedMealTypes);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                if (foodPetSettingsState.mealTypes.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Theme.of(context).primaryColorDark,
                                    onPressed: () {
                                      final updatedMealTypes =
                                          List<String>.from(
                                              foodPetSettingsState.mealTypes);
                                      updatedMealTypes.removeAt(index);
                                      _updateMealTypes(ref, updatedMealTypes);
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final updatedMealTypes = List<String>.from(
                                foodPetSettingsState.mealTypes);
                            updatedMealTypes.add('New Meal');
                            _updateMealTypes(ref, updatedMealTypes);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 60.0),
                          ),
                          child: Text(
                            'Add New Meal',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNutrientIndicator(BuildContext context, String label,
      double value, String unit, Color color, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        _showInputDialog(context, label, value, ref);
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
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
                      fontSize: 11,
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(
      BuildContext context, String label, double value, WidgetRef ref) {
    final controller = TextEditingController(text: value.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter new value for $label'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '$label Value',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            TextButton(
              onPressed: () {
                final newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  _updateNutrientValue(ref, label, newValue);
                  ref.refresh(eventFoodPetSettingsProvider(petId));
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateNutrientValue(WidgetRef ref, String label, double newValue) {
    final settingsProvider =
        ref.read(eventFoodPetSettingsProvider(petId).notifier);

    if (kDebugMode) {
      print('Updating $label with value $newValue');
    } // Debug: logowanie wartości

    switch (label.toLowerCase()) {
      case 'energy':
        settingsProvider.updateKcal(newValue);
        break;
      case 'protein':
        settingsProvider.updateProteinPercentage(newValue);
        break;
      case 'fat':
        settingsProvider.updateFatPercentage(newValue);
        break;
      case 'carbs':
        settingsProvider.updateCarbsPercentage(newValue);
        break;
      default:
        break;
    }
  }

  void _updateMealTypes(WidgetRef ref, List<String> updatedMealTypes) {
    final settingsProvider =
        ref.read(eventFoodPetSettingsProvider(petId).notifier);
    settingsProvider.updateMealTypes(updatedMealTypes);
  }
}
