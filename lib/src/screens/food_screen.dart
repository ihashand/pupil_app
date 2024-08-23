// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/category_provider.dart';
import 'package:pet_diary/src/providers/product_provider.dart';
import 'package:pet_diary/src/screens/pet_setting_screen.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/build_action_button.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/build_category_selector.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/functions/show_product_details.dart';
import 'new_product_screen.dart';

class FoodScreen extends ConsumerWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchController = TextEditingController();
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final productsAsyncValue = selectedCategory == 'all'
        ? ref.watch(globalProductsProvider)
        : selectedCategory == 'my_own'
            ? ref.watch(userProductsProvider)
            : ref.watch(favoriteProductsProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColorDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'F O O D',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings,
                  color: Theme.of(context).primaryColorDark),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PetSettingsScreen(), // Przejdź do ekranu ustawień
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(
              color: Theme.of(context).colorScheme.surface,
              height: 1.0,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).primaryColorDark),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.qr_code_scanner,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            // Akcja skanowania kodu kreskowego
                          },
                        ),
                        border: InputBorder.none,
                      ),
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildCategorySelector(
                          'All',
                          selectedCategory == 'all',
                          () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                'all';
                            ref.refresh(globalProductsProvider);
                          },
                          context,
                        ),
                      ),
                      Expanded(
                        child: buildCategorySelector(
                          'My Own',
                          selectedCategory == 'my_own',
                          () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                'my_own';
                            ref.refresh(userProductsProvider);
                          },
                          context,
                        ),
                      ),
                      Expanded(
                        child: buildCategorySelector(
                          'Favorites',
                          selectedCategory == 'favorites',
                          () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                'favorites';
                            ref.refresh(favoriteProductsProvider);
                          },
                          context,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: productsAsyncValue.when(
                data: (products) {
                  final searchTerm = searchController.text.toLowerCase();
                  final filteredProducts = products.where((product) {
                    final productName = product.name.toLowerCase();
                    final productBrand = product.brand?.toLowerCase() ?? '';
                    return productName.contains(searchTerm) ||
                        productBrand.contains(searchTerm);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          showProductDetails(context, product);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  Text(
                                    '${product.kcal} kcal, 100g',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                  if (product.fat != 0.0 ||
                                      product.carbs != 0.0 ||
                                      product.protein != 0.0)
                                    Row(
                                      children: [
                                        if (product.fat != null)
                                          Text(
                                            'Fat: ${product.fat}g  ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .primaryColorDark
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        if (product.carbs != null)
                                          Text(
                                            'Carbs: ${product.carbs}g  ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .primaryColorDark
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        if (product.protein != null)
                                          Text(
                                            'Protein: ${product.protein}g',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .primaryColorDark
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading products',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: kBottomNavigationBarHeight * 2,
          child: BottomAppBar(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.add,
                      label: 'New Product',
                      context: context,
                      small: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewProductScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.add,
                      label: 'New Recipe',
                      context: context,
                      small: true,
                      onTap: () {
                        // Implement navigation to New Recipe Screen
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.add,
                      label: 'Quick Add',
                      context: context,
                      small: true,
                      onTap: () {
                        // Implement navigation to Quick Add Screen
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
