import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_food/functions/show_new_product.dart';
import 'package:pet_diary/src/screens/events_screens/event_food_new_recipe_screen.dart';
import 'package:pet_diary/src/components/events/event_food/others/bottom_nav_action_button.dart';
import 'package:pet_diary/src/screens/events_screens/event_food_quick_add_meal_screen.dart';

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
              child: bottomNavActionButton(
                icon: Icons.add,
                label: 'New Product',
                context: context,
                small: true,
                onTap: () {
                  showNewProduct(context, ref);
                },
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: bottomNavActionButton(
                icon: Icons.add,
                label: 'New Recipe',
                context: context,
                small: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => EventFoodNewRecipeScreen(petId)),
                  );
                },
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: bottomNavActionButton(
                icon: Icons.add,
                label: 'Quick Add',
                context: context,
                small: true,
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return EventFoodQuickAddMealScreen(petId: petId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
