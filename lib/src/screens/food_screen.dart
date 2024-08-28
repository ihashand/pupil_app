import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/category_provider.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/providers/product_provider.dart';
import 'package:pet_diary/src/services/eaten_meal_service.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/_build_date_selector.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/build_category_selector.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/build_macro_circles.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/food_screen_app_bar.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/food_screen_bootom_navigation_bar.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/_is_same_day.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/show_delete_confirmation_dialog.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/show_meal_details.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/show_product_details.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class FoodScreen extends ConsumerWidget {
  final String petId;

  const FoodScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchController = TextEditingController();
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final petSettings = ref.watch(petSettingsProvider(petId));
    final eatenMealsAsyncValue = ref.watch(eatenMealsProvider(petId));

    final productsAsyncValue = selectedCategory == 'all'
        ? ref.watch(globalProductsProvider)
        : selectedCategory == 'my_own'
            ? ref.watch(userProductsProvider)
            : ref.watch(userFavoriteProductsProvider);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: foodScreenAppBar(context, petId),
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
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 2.0),
                child: Column(
                  children: [
                    if (selectedCategory == 'menu') ...[
                      buildMacroCircles(context, ref, petId),
                    ] else ...[
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
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 27.0),
                            child: buildCategorySelector(
                              'Menu',
                              selectedCategory == 'menu',
                              () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = 'menu';
                                ref.read(selectedDateProvider.notifier).state =
                                    DateTime.now();
                              },
                              context,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: buildCategorySelector(
                              'All',
                              selectedCategory == 'all',
                              () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = 'all';
                                ref.refresh(globalProductsProvider);
                              },
                              context,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: buildCategorySelector(
                              'My Own',
                              selectedCategory == 'my_own',
                              () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = 'my_own';
                                ref.refresh(userProductsProvider);
                              },
                              context,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: buildCategorySelector(
                              'Favorites',
                              selectedCategory == 'favorites',
                              () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = 'favorites';
                                ref.refresh(userFavoriteProductsProvider);
                              },
                              context,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedCategory == 'menu') ...[
                      Divider(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      buildDateSelector(context, ref),
                    ],
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              if (selectedCategory == 'menu')
                Expanded(
                  child: eatenMealsAsyncValue.when(
                    data: (meals) {
                      final mealsForSelectedDate = meals
                          .where((meal) => isSameDay(meal.date, selectedDate))
                          .toList();

                      if (mealsForSelectedDate.isEmpty) {
                        return Center(
                          child: Text(
                            'No meals found for the selected date.',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (petSettings == null ||
                          petSettings.mealTypes.isEmpty) {
                        return Center(
                          child: Text(
                            'No meal categories found. Please set up your meal types in settings.',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView(
                        children: petSettings.mealTypes.map((mealType) {
                          final mealsForType = mealsForSelectedDate
                              .where((meal) => meal.mealType == mealType)
                              .toList();

                          return Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: Text(
                                mealType,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              children: mealsForType.map((meal) {
                                return GestureDetector(
                                  onTap: () {
                                    showMealDetails(context, meal, ref, petId);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 16.0),
                                    padding: const EdgeInsets.all(14.0),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meal.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${meal.kcal.toStringAsFixed(1)} kcal, ${meal.grams.toStringAsFixed(1)} g',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Theme.of(context)
                                                      .primaryColorDark
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              if (meal.fat != null ||
                                                  meal.carbs != null ||
                                                  meal.protein != null)
                                                Row(
                                                  children: [
                                                    if (meal.fat != null)
                                                      Text(
                                                        'Fat: ${meal.fat?.toStringAsFixed(1)}g  ',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    if (meal.carbs != null)
                                                      Text(
                                                        'Carbs: ${meal.carbs?.toStringAsFixed(1)}g  ',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    if (meal.protein != null)
                                                      Text(
                                                        'Protein: ${meal.protein?.toStringAsFixed(1)}g',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDeleteConfirmationDialog(
                                                context, ref, meal, petId);
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            child: Icon(
                                              Icons.delete,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading meals',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: productsAsyncValue.when(
                    data: (products) {
                      if (products.isEmpty && selectedCategory == 'favorites') {
                        return Center(
                          child: Text(
                            'No favorites yet. Tap the heart icon to add some!',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                            ),
                          ),
                        );
                      } else if (products.isEmpty) {
                        return Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isFavorite = ref
                              .watch(favoriteProductsNotifierProvider)
                              .any((p) => p.id == product.id);

                          return GestureDetector(
                            onTap: () {
                              showProductDetails(context, product, petId);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        Text(
                                          '${product.kcal.toStringAsFixed(1)} kcal, 100g',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : Theme.of(context).primaryColorDark,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(favoriteProductsNotifierProvider
                                              .notifier)
                                          .toggleFavorite(product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
          bottomNavigationBar: foodScreenBootomNavigationBar(context, ref),
        ));
  }
}
