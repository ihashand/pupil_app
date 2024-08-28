import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/food_recipe_model.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/providers/food_recipe_service_provider.dart';
import 'package:pet_diary/src/providers/product_provider.dart';

class NewRecipeScreen extends ConsumerStatefulWidget {
  const NewRecipeScreen({super.key});

  @override
  _NewRecipeScreenState createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends ConsumerState<NewRecipeScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ingredientControllers = <Map<String, dynamic>>[];
  final preparationStepControllers = <TextEditingController>[];
  final preparationTimeController = TextEditingController();

  bool isGlobal = true;

  void submitRecipe() async {
    if (formKey.currentState?.validate() ?? false) {
      final newRecipe = FoodRecipeModel(
        id: UniqueKey().toString(),
        name: nameController.text,
        ingredients: ingredientControllers.map((ingredient) {
          return '${ingredient['name']} (${ingredient['amount']} ${ingredient['unit']})';
        }).toList(),
        preparationSteps: preparationStepControllers
            .map((controller) => controller.text)
            .toList(),
        preparationTime: preparationTimeController.text.isEmpty
            ? null
            : int.tryParse(preparationTimeController.text),
      );

      final recipeService = ref.read(foodRecipeServiceProvider);

      await recipeService.addFoodRecipe(newRecipe, isGlobal: isGlobal);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  void addIngredient(String name, String unit) {
    setState(() {
      ingredientControllers.add({
        'name': name,
        'amount': TextEditingController(),
        'unit': unit,
      });
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: submitRecipe,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
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
              const SizedBox(height: 10),
              Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              ...ingredientControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${ingredient['name']} (${ingredient['unit']})'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: ingredient['amount'],
                          decoration: InputDecoration(
                            labelText: 'Amount',
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
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).primaryColorDark,
                        onPressed: () => removeIngredient(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
              TextButton(
                onPressed: () async {
                  // Otwórz wyszukiwanie składnika
                  final selectedProduct = await showSearch<ProductModel?>(
                    context: context,
                    delegate: ProductSearchDelegate(ref),
                  );
                  if (selectedProduct != null) {
                    addIngredient(selectedProduct.name, 'g');
                  }
                },
                child: const Text('Add Ingredient'),
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Preparation Steps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              ...preparationStepControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Step ${index + 1}',
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).primaryColorDark,
                        onPressed: () => removePreparationStep(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
              TextButton(
                onPressed: addPreparationStep,
                child: const Text('Add Step'),
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
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
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<ProductModel?> {
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
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildProductList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildProductList();
  }

  Widget _buildProductList() {
    final productsAsyncValue = ref.watch(globalProductsProvider);

    return productsAsyncValue.when(
      data: (products) {
        final filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('${product.kcal} kcal per 100g'),
              onTap: () {
                close(context, product);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading products: $error'),
      ),
    );
  }
}
