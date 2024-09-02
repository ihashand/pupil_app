// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_food/functions/show_ingredient_details.dart';
import 'package:pet_diary/src/components/events/event_food/others/nutrient_new_recipe.dart';
import 'package:pet_diary/src/components/events/event_food/others/product_search_delegate.dart';
import 'package:pet_diary/src/models/events_models/event_food_recipe_model.dart';
import 'package:pet_diary/src/models/others/product_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';

class EventFoodNewRecipeScreen extends ConsumerStatefulWidget {
  const EventFoodNewRecipeScreen(this.petId, {super.key});
  final String petId;

  @override
  createState() => EventFoodNewRecipeScreenState();
}

class EventFoodNewRecipeScreenState
    extends ConsumerState<EventFoodNewRecipeScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ingredientControllers = <Map<String, dynamic>>[];
  final preparationStepControllers = <TextEditingController>[];
  final preparationTimeController = TextEditingController();

  bool isGlobal = true;

  void submitRecipe() async {
    final totalKcal = calculateTotalKcal();
    final totalProtein = calculateTotalProtein();
    final totalFat = calculateTotalFat();
    final totalCarbs = calculateTotalCarbs();

    if (formKey.currentState?.validate() ?? false) {
      final newRecipe = EventFoodRecipeModel(
        id: UniqueKey().toString(),
        name: nameController.text,
        ingredients: ingredientControllers.map((ingredient) {
          final product = ingredient['product'] as ProductModel;
          final amount = double.tryParse(ingredient['amount'].text) ?? 0.0;
          return '${product.name} - ${amount.toStringAsFixed(0)}g';
        }).toList(),
        preparationSteps: preparationStepControllers
            .map((controller) => controller.text)
            .toList(),
        preparationTime: preparationTimeController.text.isEmpty
            ? null
            : int.tryParse(preparationTimeController.text),
        totalKcal: totalKcal,
        totalProtein: totalProtein,
        totalFat: totalFat,
        totalCarbs: totalCarbs,
      );

      final recipeService = ref.read(eventFoodRecipeServiceProvider);

      await recipeService.addFoodRecipe(newRecipe, widget.petId,
          isGlobal: isGlobal);

      Navigator.of(context).pop();
    }
  }

  void addIngredient(ProductModel product, String unit, double amount) {
    setState(() {
      ingredientControllers.add({
        'product': product,
        'amount': TextEditingController(text: amount.toString()),
        'unit': unit,
      });
    });
    updateTotals();
  }

  void removeIngredient(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
    updateTotals();
  }

  void addPreparationStep() {
    setState(() {
      preparationStepControllers.add(TextEditingController());
    });
  }

  void removePreparationStep(int index) {
    setState(() {
      preparationStepControllers.removeAt(index);
    });
  }

  void updateTotals() {
    setState(() {
      calculateTotalKcal();
      calculateTotalProtein();
      calculateTotalFat();
      calculateTotalCarbs();
    });
  }

  double calculateTotalKcal() {
    double totalKcal = 0.0;

    for (var ingredient in ingredientControllers) {
      final product = ingredient['product'] as ProductModel;
      final amount = double.tryParse(ingredient['amount'].text) ?? 0.0;
      totalKcal += (product.kcal) * (amount / 100);
    }

    return totalKcal;
  }

  double calculateTotalProtein() {
    double totalProtein = 0.0;

    for (var ingredient in ingredientControllers) {
      final product = ingredient['product'] as ProductModel;
      final amount = double.tryParse(ingredient['amount'].text) ?? 0.0;
      totalProtein += (product.protein ?? 0) * (amount / 100);
    }

    return totalProtein;
  }

  double calculateTotalFat() {
    double totalFat = 0.0;

    for (var ingredient in ingredientControllers) {
      final product = ingredient['product'] as ProductModel;
      final amount = double.tryParse(ingredient['amount'].text) ?? 0.0;
      totalFat += (product.fat ?? 0) * (amount / 100);
    }

    return totalFat;
  }

  double calculateTotalCarbs() {
    double totalCarbs = 0.0;

    for (var ingredient in ingredientControllers) {
      final product = ingredient['product'] as ProductModel;
      final amount = double.tryParse(ingredient['amount'].text) ?? 0.0;
      totalCarbs += (product.carbs ?? 0) * (amount / 100);
    }

    return totalCarbs;
  }

  Widget buildNutrientTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NutrientNewRecipe(
                    context: context,
                    label: 'Kcal',
                    value: calculateTotalKcal().roundToDouble(),
                    color: Colors.red),
                NutrientNewRecipe(
                    context: context,
                    label: 'Protein',
                    value: calculateTotalProtein(),
                    color: Colors.orange),
                NutrientNewRecipe(
                    context: context,
                    label: 'Fat',
                    value: calculateTotalFat(),
                    color: Colors.purple),
                NutrientNewRecipe(
                    context: context,
                    label: 'Carbs',
                    value: calculateTotalCarbs(),
                    color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'N E W  R E C I P E',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: submitRecipe,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildNutrientTable(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColorDark,
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Recipe Name',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a recipe name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColorDark,
                        controller: preparationTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Preparation Time (minutes)',
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
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text('Add to Global Database'),
                        value: isGlobal,
                        onChanged: (bool value) {
                          setState(() {
                            isGlobal = value;
                          });
                        },
                        subtitle: Text(
                          isGlobal
                              ? 'This recipe will be visible to all users'
                              : 'This recipe will be visible only to you',
                          style: TextStyle(
                            color: isGlobal
                                ? Theme.of(context).primaryColorDark
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        activeColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...ingredientControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ingredient = entry.value;
                        final product = ingredient['product'] as ProductModel;
                        final amount =
                            double.tryParse(ingredient['amount'].text) ?? 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  iconSize: 25,
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.7),
                                  onPressed: () => removeIngredient(index),
                                ),
                              ],
                            ),
                            Text(
                              '${(product.kcal * (amount / 100)).round()} kcal  '
                              '${((product.protein ?? 0) * (amount / 100)).toStringAsFixed(2)} protein  '
                              '${((product.fat ?? 0) * (amount / 100)).toStringAsFixed(2)} fat  '
                              '${((product.carbs ?? 0) * (amount / 100)).toStringAsFixed(2)} carbs',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 13,
                              ),
                            ),
                            Divider(
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          ],
                        );
                      }),
                      SizedBox(
                          height:
                              ingredientControllers.isNotEmpty ? 20.0 : 0.0),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final selectedProduct = await showSearch(
                              context: context,
                              delegate: ProductSearchDelegate(ref),
                            );
                            if (selectedProduct != null &&
                                selectedProduct.name != '') {
                              showIngredientDetails(
                                  context, selectedProduct, ref,
                                  (product, unit, amount) {
                                addIngredient(product, unit, amount);
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColorDark,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryFixed,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Add Ingredient'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...preparationStepControllers
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor:
                                      Theme.of(context).primaryColorDark,
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Step ${index + 1}',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () => removePreparationStep(index),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(
                          height: preparationStepControllers.isNotEmpty
                              ? 20.0
                              : 0.0),
                      Center(
                        child: TextButton(
                          onPressed: addPreparationStep,
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColorDark,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryFixedDim,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Add Steps'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
