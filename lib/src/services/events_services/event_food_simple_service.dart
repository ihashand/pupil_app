import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_food_simple_model.dart';

class EventFoodSimpleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Pamięć podręczna dla jednorazowych odczytów
  List<EventFoodSimpleModel>? _cachedFoodEvents;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration =
      const Duration(minutes: 5); // okres ważności cache

  Future<List<EventFoodSimpleModel>> getFoodEventsOnce(String petId) async {
    if (_cachedFoodEvents != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      // Zwraca dane z cache, jeśli są aktualne
      return _cachedFoodEvents!;
    }

    // Wykonaj zapytanie jednorazowe do Firestore
    final querySnapshot = await _firestore
        .collection('food_simple_events')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser?.uid) // filtrowanie po userId
        .get();

    _cachedFoodEvents = querySnapshot.docs
        .map((doc) => EventFoodSimpleModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedFoodEvents!;
  }

  Stream<List<EventFoodSimpleModel>> getFoodEventsStream(String petId) {
    // Stream, który jest inicjowany tylko wtedy, gdy jest to konieczne
    return _firestore
        .collection('food_simple_events')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser?.uid) // filtrowanie po userId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventFoodSimpleModel.fromDocument(doc))
          .toList();
    });
  }

  Future<void> addFood(EventFoodSimpleModel foodEvent) async {
    await _firestore
        .collection('food_simple_events')
        .doc(foodEvent.id)
        .set(foodEvent.toMap());
    _cachedFoodEvents = null; // Czyszczenie cache po dodaniu nowych danych
  }

  Future<void> updateFood(EventFoodSimpleModel foodEvent) async {
    await _firestore
        .collection('food_simple_events')
        .doc(foodEvent.id)
        .update(foodEvent.toMap());
    _cachedFoodEvents = null; // Czyszczenie cache po aktualizacji danych
  }

  Future<void> deleteFood(String id) async {
    await _firestore.collection('food_simple_events').doc(id).delete();
    _cachedFoodEvents = null; // Czyszczenie cache po usunięciu danych
  }
}
