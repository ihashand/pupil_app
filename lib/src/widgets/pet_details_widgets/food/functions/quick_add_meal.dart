import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/services/eaten_meal_service.dart';
import 'package:pet_diary/src/models/events_models/event_eaten_meal_model.dart';

class QuickAddMealScreen extends StatefulWidget {
  final String petId;

  const QuickAddMealScreen({Key? key, required this.petId}) : super(key: key);

  @override
  _QuickAddMealScreenState createState() => _QuickAddMealScreenState();
}

class _QuickAddMealScreenState extends State<QuickAddMealScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gramsController =
      TextEditingController(text: '100');
  final TextEditingController kcalController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );

  String selectedUnit = 'g';
  String mealType = ''; // Zmienne mealType

  double grams = 100.0;

  @override
  void dispose() {
    nameController.dispose();
    gramsController.dispose();
    kcalController.dispose();
    proteinController.dispose();
    fatController.dispose();
    carbsController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void updateValues() {
    double factor = double.tryParse(gramsController.text) ?? 100.0;
    if (selectedUnit == 'kg') {
      factor *= 1000;
    }
    grams = factor;
  }

  void handleInput(String value) {
    value = value.replaceAll(',', '.');
    setState(() {
      gramsController.text = value;
      gramsController.selection = TextSelection.fromPosition(
        TextPosition(offset: gramsController.text.length),
      );
      updateValues();
    });
  }

  void handleMacroInput(String value, TextEditingController controller) {
    value = value.replaceAll(',', '.');
    setState(() {
      controller.text = value;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }

  void validateAndSave(BuildContext context, WidgetRef ref) async {
    String errorMessage = '';

    if (nameController.text.isEmpty) {
      errorMessage += 'Name cannot be empty.\n';
    }

    if (grams > 5000) {
      errorMessage += 'Weight cannot exceed 5000 grams.\n';
    }

    if (grams < 0) {
      errorMessage += 'Weight cannot be negative.\n';
    }

    if (kcalController.text.isEmpty ||
        double.tryParse(kcalController.text) == 0) {
      errorMessage += 'Calories cannot be empty or zero.\n';
    }

    if (errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Validation Error',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            content: Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            actions: [
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      final eatenMeal = EventEatenMealModel(
        id: '',
        date: DateFormat('dd-MM-yyyy').parse(dateController.text),
        mealType: mealType, // Zapisujemy poprawny mealType
        name: nameController.text,
        kcal: double.parse(kcalController.text),
        fat: fatController.text.isNotEmpty
            ? double.parse(fatController.text)
            : 0.0,
        carbs: carbsController.text.isNotEmpty
            ? double.parse(carbsController.text)
            : 0.0,
        protein: proteinController.text.isNotEmpty
            ? double.parse(proteinController.text)
            : 0.0,
        grams: grams,
      );

      await ref
          .read(eatenMealServiceProvider)
          .addEatenMeal(widget.petId, eatenMeal);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final petSettingsFuture =
            ref.watch(petSettingsStreamProvider(widget.petId));

        return petSettingsFuture.when(
          data: (settings) {
            if (settings == null) {
              return Center(
                child: Text(
                  'No settings found for this pet.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 16,
                  ),
                ),
              );
            }

            mealType = mealType.isNotEmpty
                ? mealType
                : settings
                    .mealTypes.first; // Ustawienie domyślnej wartości mealType

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const Flexible(
                            child: Text(
                              'Quick Add Meal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => validateAndSave(context, ref),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      height: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: TextField(
                        cursorColor: Theme.of(context).primaryColorDark,
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Meal Name',
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: mealType,
                              decoration: InputDecoration(
                                labelText: 'Meal Type',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              items: settings.mealTypes
                                  .map((meal) => DropdownMenuItem(
                                        value: meal,
                                        child: Text(meal),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  mealType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColorDark,
                              controller: dateController,
                              decoration: InputDecoration(
                                labelText: 'Select Date',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          onPrimary: Theme.of(context)
                                              .primaryColorDark,
                                          onSurface: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    dateController.text =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColorDark,
                              controller: kcalController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Calories (kcal)',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              onChanged: (value) =>
                                  handleMacroInput(value, kcalController),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColorDark,
                              controller: gramsController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Weight',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              onChanged: handleInput,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColorDark,
                              controller: proteinController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Protein (g)',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              onChanged: (value) =>
                                  handleMacroInput(value, proteinController),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColorDark,
                              controller: fatController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Fat (g)',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              onChanged: (value) =>
                                  handleMacroInput(value, fatController),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColorDark,
                              controller: carbsController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Carbs (g)',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
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
                              onChanged: (value) =>
                                  handleMacroInput(value, carbsController),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading settings',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

void quickAddMeal(BuildContext context, String petId) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return QuickAddMealScreen(petId: petId);
    },
  );
}
