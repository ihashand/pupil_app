import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/eaten_meal_model.dart';
import 'package:pet_diary/src/providers/category_provider.dart';
import 'package:pet_diary/src/providers/pet_settings_provider.dart';
import 'package:pet_diary/src/providers/product_provider.dart';
import 'package:pet_diary/src/screens/new_product_screen.dart';
import 'package:pet_diary/src/screens/pet_setting_screen.dart';
import 'package:pet_diary/src/services/eaten_meal_service.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/build_action_button.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/build_category_selector.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/functions/show_product_details.dart';
import 'package:intl/intl.dart';

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
                    builder: (context) => PetSettingsScreen(
                      petId: petId,
                    ),
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
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 2.0),
              child: Column(
                children: [
                  if (selectedCategory == 'menu') ...[
                    _buildMacroCircles(context, ref),
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
                    _buildDateSelector(context, ref),
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
                        .where((meal) => _isSameDay(meal.date, selectedDate))
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

                    if (petSettings == null || petSettings.mealTypes.isEmpty) {
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
                                  _showMealDetails(context, meal, ref, petId);
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
                                      Column(
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
                                                      color: Theme.of(context)
                                                          .primaryColorDark
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                if (meal.carbs != null)
                                                  Text(
                                                    'Carbs: ${meal.carbs?.toStringAsFixed(1)}g  ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .primaryColorDark
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                if (meal.protein != null)
                                                  Text(
                                                    'Protein: ${meal.protein?.toStringAsFixed(1)}g',
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
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        child: Icon(
                                          Icons.delete,
                                          color: Theme.of(context)
                                              .primaryColorDark,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        showNewProductBottomSheet(context, ref);
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

  Widget _buildMacroCircles(BuildContext context, WidgetRef ref) {
    final petSettings = ref.watch(petSettingsProvider(petId));
    final eatenMealsAsyncValue = ref.watch(eatenMealsProvider(petId));

    return eatenMealsAsyncValue.when(
      data: (meals) {
        final mealsForSelectedDate = meals
            .where((meal) =>
                _isSameDay(meal.date, ref.watch(selectedDateProvider)))
            .toList();

        double totalKcal =
            mealsForSelectedDate.fold(0.0, (sum, meal) => sum + (meal.kcal));
        double totalFat = mealsForSelectedDate.fold(
            0.0, (sum, meal) => sum + (meal.fat ?? 0.0));
        double totalCarbs = mealsForSelectedDate.fold(
            0.0, (sum, meal) => sum + (meal.carbs ?? 0.0));
        double totalProtein = mealsForSelectedDate.fold(
            0.0, (sum, meal) => sum + (meal.protein ?? 0.0));

        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientCircle(
                  context, 'Kcal', totalKcal, petSettings?.dailyKcal ?? 0.0),
              _buildNutrientCircle(
                  context, 'Fat', totalFat, petSettings?.fatPercentage ?? 0.0),
              _buildNutrientCircle(context, 'Carbs', totalCarbs,
                  petSettings?.carbsPercentage ?? 0.0),
              _buildNutrientCircle(context, 'Protein', totalProtein,
                  petSettings?.proteinPercentage ?? 0.0),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const SizedBox(),
    );
  }

  Widget _buildNutrientCircle(
      BuildContext context, String label, double consumed, double dailyGoal) {
    double fillPercentage = _calculateFill(consumed, dailyGoal);

    Color circleColor;
    switch (label) {
      case 'Fat':
        circleColor = Colors.purple;
        break;
      case 'Carbs':
        circleColor = Colors.green;
        break;
      case 'Protein':
        circleColor = Colors.orange;
        break;
      default:
        circleColor = Colors.blue;
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 75,
              height: 75,
              child: CircularProgressIndicator(
                value: fillPercentage,
                strokeWidth: 5,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(circleColor),
              ),
            ),
            Column(
              children: [
                Text(
                  consumed.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${(fillPercentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateFill(double consumed, double dailyGoal) {
    return dailyGoal == 0 ? 0 : consumed / dailyGoal;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showMealDetails(
      BuildContext context, EatenMealModel meal, WidgetRef ref, String petId) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.primary,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Confirm Deletion',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              content: Text(
                                'Are you sure you want to delete ${meal.name}?',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                  onPressed: () {
                                    _deleteMeal(ref, meal, petId);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
                height: 32,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 35.0, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Kcal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.8),
                          ),
                        ),
                        Text(
                          meal.kcal.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Fat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${meal.fat?.toStringAsFixed(1) ?? '0.0'}g',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Carbs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${meal.carbs?.toStringAsFixed(1) ?? '0.0'}g',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Protein',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${meal.protein?.toStringAsFixed(1) ?? '0.0'}g',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
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
  }

  void _deleteMeal(WidgetRef ref, EatenMealModel meal, String petId) async {
    await ref.read(eatenMealServiceProvider).deleteEatenMeal(petId, meal.id);
  }

  Widget _buildDateSelector(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final formattedDate = _getFormattedDate(selectedDate, today);

    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          ref.read(selectedDateProvider.notifier).state = pickedDate;
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_left,
                color: Theme.of(context).primaryColorDark),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state =
                  selectedDate.subtract(const Duration(days: 1));
            },
          ),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right,
                color: Theme.of(context).primaryColorDark),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state =
                  selectedDate.add(const Duration(days: 1));
            },
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime selectedDate, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (selectedDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (selectedDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else if (selectedDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yyyy').format(selectedDate);
    }
  }
}
