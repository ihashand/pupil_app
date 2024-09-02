import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/new_product_bottom_sheet.dart';
import 'package:pet_diary/src/screens/new_recipe_screen.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/build_action_button.dart';
import 'package:pet_diary/src/widgets/pet_details_widgets/food/functions/quick_add_meal.dart';

SizedBox foodScreenBootomNavigationBar(
    BuildContext context, WidgetRef ref, String petId) {
  return SizedBox(
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
                  newProductBottomSheet(context, ref);
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => NewRecipeScreen(petId)),
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
                label: 'Quick Add',
                context: context,
                small: true,
                onTap: () {
                  quickAddMeal(context, petId);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
