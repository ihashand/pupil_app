import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/food_recipe_model.dart';

class FoodRecipeService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addFoodRecipe(FoodRecipeModel recipe, String petId,
      {bool isGlobal = true}) async {
    if (isGlobal) {
      await _firestore.collection('global_recipes').add(recipe.toMap());
    } else {
      if (_currentUser != null) {
        await _firestore
            .collection('app_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('pets')
            .doc(petId)
            .collection('user_recipes')
            .add(recipe.toMap());
      }
    }
  }
}
