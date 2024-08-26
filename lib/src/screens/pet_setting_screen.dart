import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/smart_goal.dart';

class PetSettingsScreen extends ConsumerWidget {
  final String petId;

  const PetSettingsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petSettingsState = ref.watch(petSettingsProvider(petId));

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
      body: petSettingsState == null
          ? _buildDefaultSettings(
              context, ref) // Create default settings if none exist
          : _buildSettingsView(context, ref, petSettingsState),
    );
  }

  Widget _buildDefaultSettings(BuildContext context, WidgetRef ref) {
    final settingsProvider = ref.read(petSettingsProvider(petId).notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set default settings: 3 meals (Breakfast, Lunch, Dinner) and kcal/macros to 0
      settingsProvider.setDefaultSettings(
        mealTypes: ['Breakfast', 'Lunch', 'Dinner'],
        dailyKcal: 0,
        proteinPercentage: 0,
        fatPercentage: 0,
        carbsPercentage: 0,
      );
    });

    return Center(
      child: Text(
        'No settings found for this pet. Default settings have been applied.',
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSettingsView(
      BuildContext context, WidgetRef ref, PetSettingsState petSettingsState) {
    return ListView(
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
                        petSettingsState.dailyKcal.toDouble(),
                        'kcal',
                        Colors.blue,
                        ref),
                    _buildNutrientIndicator(
                        context,
                        'Protein',
                        petSettingsState.proteinPercentage,
                        'g',
                        Colors.orange,
                        ref),
                    _buildNutrientIndicator(
                        context,
                        'Fat',
                        petSettingsState.fatPercentage,
                        'g',
                        Colors.purple,
                        ref),
                    _buildNutrientIndicator(
                        context,
                        'Carbs',
                        petSettingsState.carbsPercentage,
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 80.0),
                  ),
                  child: Text(
                    'Smart Goal',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 285,
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
              ...List.generate(petSettingsState.mealTypes.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final controller = TextEditingController(
                              text: petSettingsState.mealTypes[index],
                            );
                            return TextField(
                              decoration: InputDecoration(
                                labelText: 'Meal ${index + 1}',
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
                              controller: controller,
                              onChanged: (value) {
                                final updatedMealTypes = List<String>.from(
                                    petSettingsState.mealTypes);
                                updatedMealTypes[index] = value;
                                _updateMealTypes(ref, updatedMealTypes);
                              },
                            );
                          },
                        ),
                      ),
                      if (petSettingsState.mealTypes.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () {
                            final updatedMealTypes =
                                List<String>.from(petSettingsState.mealTypes);
                            updatedMealTypes.removeAt(index);
                            _updateMealTypes(ref, updatedMealTypes);
                          },
                        ),
                    ],
                  ),
                );
              }),
              if (petSettingsState.mealTypes.length < 8)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedMealTypes =
                            List<String>.from(petSettingsState.mealTypes);
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
                        'Add Meal Type',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                    ),
                  ),
                ),
              if (petSettingsState.mealTypes.length == 8)
                Text(
                  'Maximum number of meal types reached.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ],
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
    final settingsProvider = ref.read(petSettingsProvider(petId).notifier);

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
    final settingsProvider = ref.read(petSettingsProvider(petId).notifier);
    settingsProvider.updateMealTypes(updatedMealTypes);
  }
}
