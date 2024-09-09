import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:pet_diary/src/models/events_models/event_food_recipe_model.dart';
import 'package:pet_diary/src/models/others/product_model.dart';
import 'package:pet_diary/src/providers/others_providers/category_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_recipe_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_pet_settings_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_product_provider.dart';
import 'package:pet_diary/services/events_services/event_food_eaten_meal_service.dart';
import 'package:pet_diary/src/components/events/event_food/others/date_selector.dart';
import 'package:pet_diary/src/components/events/event_food/others/caregory_selector.dart';
import 'package:pet_diary/src/components/events/event_food/others/food_screen_macro_circles.dart';
import 'package:pet_diary/src/components/events/event_food/others/food_screen_app_bar.dart';
import 'package:pet_diary/src/components/events/event_food/others/food_screen_bootom_navigation_bar.dart';
import 'package:pet_diary/src/components/events/event_food/functions/is_same_day.dart';
import 'package:pet_diary/src/components/events/event_food/functions/show_delete_confirmation_dialog.dart';
import 'package:pet_diary/src/components/events/event_food/functions/show_meal_details.dart';
import 'package:pet_diary/src/components/events/event_food/functions/show_product_details.dart';
import 'package:pet_diary/src/components/events/event_food/functions/show_recipe_details.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final searchQueryProvider = StateProvider<String>((ref) => '');

class FoodScreen extends ConsumerStatefulWidget {
  final String petId;

  const FoodScreen({super.key, required this.petId});

  @override
  createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = searchController.text;
    });
  }

  Future<void> scanBarcodeOrQrCode() async {
    var result = await BarcodeScanner.scan();
    if (result.type == ResultType.Barcode) {
      setState(() {
        searchController.text = result.rawContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final petSettings = ref.watch(eventFoodPetSettingsProvider(widget.petId));
    final searchQuery = ref.watch(searchQueryProvider);

    AsyncValue<List<ProductModel>> productsAsyncValue;
    AsyncValue<List<EventFoodRecipeModel>> recipesAsyncValue;

    if (selectedCategory == 'all') {
      productsAsyncValue = ref.watch(eventGlobalProductsProvider);
      recipesAsyncValue = ref.watch(eventGlobalRecipesProvider);
    } else if (selectedCategory == 'my_own') {
      productsAsyncValue = ref.watch(eventUserProductsProvider);
      recipesAsyncValue = ref.watch(eventUserRecipesProvider);
    } else if (selectedCategory == 'favorites') {
      productsAsyncValue = ref.watch(eventUserFavoriteProductsProvider);
      recipesAsyncValue = ref.watch(eventUserFavoriteRecipesProvider);
    } else {
      productsAsyncValue = const AsyncValue.data([]);
      recipesAsyncValue = const AsyncValue.data([]);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: foodScreenAppBar(context, widget.petId),
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
                    foodScreenMacroCircles(context, ref, widget.petId),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        showCursor: true,
                        cursorColor: Theme.of(context).primaryColorDark,
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search,
                              color: Theme.of(context).primaryColorDark),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.qr_code_scanner,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: scanBarcodeOrQrCode,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                  ],
                  if (selectedCategory == 'menu') const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 27.0),
                          child: categorySelector(
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
                          child: categorySelector(
                            'All',
                            selectedCategory == 'all',
                            () {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = 'all';
                            },
                            context,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: categorySelector(
                            'My Own',
                            selectedCategory == 'my_own',
                            () {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = 'my_own';
                            },
                            context,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: categorySelector(
                            'Favorites',
                            selectedCategory == 'favorites',
                            () {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = 'favorites';
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
                    dateSelector(context, ref),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 5),
            if (selectedCategory == 'menu')
              Expanded(
                child: ref
                    .watch(eventFoodEatenMealsProvider(widget.petId))
                    .when(
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
                                      showMealDetails(
                                          context, meal, ref, widget.petId);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 16.0),
                                      padding: const EdgeInsets.all(14.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                                .withOpacity(
                                                                    0.8),
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
                                                                .withOpacity(
                                                                    0.8),
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
                                                                .withOpacity(
                                                                    0.8),
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
                                                  context,
                                                  ref,
                                                  meal,
                                                  widget.petId);
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
                      error: (err, stack) => Center(
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
                    return recipesAsyncValue.when(
                      data: (recipes) {
                        final combinedItems = [...products, ...recipes];

                        final filteredItems = combinedItems.where((item) {
                          final searchLower = searchQuery.toLowerCase();
                          if (item is ProductModel) {
                            return item.name
                                    .toLowerCase()
                                    .contains(searchLower) ||
                                (item.barcode
                                        ?.toLowerCase()
                                        .contains(searchLower) ??
                                    false);
                          } else if (item is EventFoodRecipeModel) {
                            return item.name
                                .toLowerCase()
                                .contains(searchLower);
                          }
                          return false;
                        }).toList();

                        if (filteredItems.isEmpty) {
                          return Center(
                            child: Text(
                              'No items found.',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            if (item is ProductModel) {
                              final isFavorite = ref
                                  .watch(eventFavoriteProductsNotifierProvider)
                                  .any((p) => p.id == item.id);

                              return GestureDetector(
                                onTap: () {
                                  showProductDetails(
                                      context, item, widget.petId);
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
                                              item.name,
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
                                              '${item.kcal.toStringAsFixed(1)} kcal, 100g',
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
                                              : Theme.of(context)
                                                  .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                  eventFavoriteProductsNotifierProvider
                                                      .notifier)
                                              .toggleFavorite(item);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (item is EventFoodRecipeModel) {
                              final isFavorite = ref
                                  .watch(favoriteRecipesNotifierProvider)
                                  .any((r) => r.id == item.id);

                              return GestureDetector(
                                onTap: () {
                                  showRecipeDetails(
                                      context, item, widget.petId);
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
                                              item.name,
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
                                              '${item.totalKcal.toStringAsFixed(1)} kcal',
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
                                              : Theme.of(context)
                                                  .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                  favoriteRecipesNotifierProvider
                                                      .notifier)
                                              .toggleFavorite(item);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(
                        child: Text(
                          'Error loading recipes',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
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
        bottomNavigationBar:
            foodScreenBootomNavigationBar(context, ref, widget.petId),
      ),
    );
  }
}
