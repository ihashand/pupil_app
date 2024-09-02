import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_eaten_meal_model.dart';

final eventFoodEatenMealServiceProvider =
    Provider<EventFoodEatenMealService>((ref) {
  return EventFoodEatenMealService();
});

final eventFoodEatenMealsProvider =
    StreamProvider.family<List<EventEatenMealModel>, String>((ref, petId) {
  return ref.read(eventFoodEatenMealServiceProvider).getEatenMealsStream(petId);
});

class EventFoodEatenMealService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<EventEatenMealModel>> getEatenMealsStream(String petId) {
    return _firestore
        .collection('app_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_food_eaten_meals')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventEatenMealModel.fromDocument(doc))
            .toList());
  }

  Future<void> addEatenMeal(String petId, EventEatenMealModel meal) async {
    await _firestore
        .collection('app_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_food_eaten_meals')
        .add(meal.toMap());
  }

  Future<void> deleteEatenMeal(String petId, String mealId) async {
    await _firestore
        .collection('app_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_food_eaten_meals')
        .doc(mealId)
        .delete();
  }
}
