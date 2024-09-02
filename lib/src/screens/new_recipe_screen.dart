// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_food_recipe_model.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';

class NewRecipeScreen extends ConsumerStatefulWidget {
  const NewRecipeScreen(this.petId, {super.key});

  final String petId;

  @override
  createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends ConsumerState<NewRecipeScreen> {
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
                buildNutrientColumn(context, 'Kcal',
                    calculateTotalKcal().roundToDouble(), Colors.red),
                buildNutrientColumn(
                    context, 'Protein', calculateTotalProtein(), Colors.orange),
                buildNutrientColumn(
                    context, 'Fat', calculateTotalFat(), Colors.purple),
                buildNutrientColumn(
                    context, 'Carbs', calculateTotalCarbs(), Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNutrientColumn(
      BuildContext context, String label, double value, Color color) {
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
                            if (selectedProduct != null) {
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

  void showIngredientDetails(BuildContext context, ProductModel product,
      WidgetRef ref, Function(ProductModel, String, double) onSave) {
    TextEditingController amountController = TextEditingController();
    String selectedUnit = 'g';
    double grams = 100.0;

    void updateValues(StateSetter setState) {
      setState(() {
        double factor = double.tryParse(amountController.text) ?? 100.0;
        if (selectedUnit == 'kg') {
          factor *= 1000;
        }
        grams = factor;
      });
    }

    void handleInput(String value, StateSetter setState) {
      value = value.replaceAll(',', '.');
      setState(() {
        amountController.text = value;
        amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: amountController.text.length),
        );
        updateValues(setState);
      });
    }

    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.primary,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double kcal = (product.kcal * grams) / 100;
            double protein = ((product.protein ?? 0) * grams) / 100;
            double fat = ((product.fat ?? 0) * grams) / 100;
            double carbs = ((product.carbs ?? 0) * grams) / 100;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, left: 25.0, right: 10),
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 15),
                        child: IconButton(
                          iconSize: 27,
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            double? amount =
                                double.tryParse(amountController.text);
                            if (amount != null) {
                              onSave(product, selectedUnit, amount);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            cursorColor: Theme.of(context).primaryColorDark,
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                            ),
                            onChanged: (value) => handleInput(value, setState),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedUnit,
                          items: ['g', 'kg', 'ml']
                              .map((unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUnit = value!;
                              updateValues(setState);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              kcal.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Kcal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${(protein % 1 == 0 ? protein.toStringAsFixed(0) : protein.toStringAsFixed(2))}g',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Protein',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${(fat % 1 == 0 ? fat.toStringAsFixed(0) : fat.toStringAsFixed(2))}g',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Fat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${(carbs % 1 == 0 ? carbs.toStringAsFixed(0) : carbs.toStringAsFixed(2))}g',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Carbs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<ProductModel> {
  final WidgetRef ref;

  ProductSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ProductModel(id: '', name: '', kcal: 0));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildProductList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildProductList(context);
  }

  Widget _buildProductList(BuildContext context) {
    final productsAsyncValue = ref.watch(eventGlobalProductsProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: productsAsyncValue.when(
        data: (products) {
          final filteredProducts = products.where((product) {
            return product.name.toLowerCase().contains(query.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(product.name,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    subtitle: Text(
                        '${product.kcal.toStringAsFixed(1)} kcal per 100g',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    onTap: () {
                      close(context, product);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading products: $error'),
        ),
      ),
    );
  }
}
