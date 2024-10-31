import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';

class EventUrineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  // Kontroler do zarządzania cachem i streamem dla aktualizacji w czasie rzeczywistym
  final _urineEventsController =
      StreamController<List<EventUrineModel>>.broadcast();

  // Cache dla pobranych eventów, aby zoptymalizować wydajność
  List<EventUrineModel> _cachedUrineEvents =
      []; // Inicjalizacja jako pusta lista

  /// Strumień zapewniający aktualizacje w czasie rzeczywistym dla eventów urine dla danego `petId`
  Stream<List<EventUrineModel>> getUrineEventsStream(String petId) {
    if (_currentUser == null) {
      return Stream.value(
          []); // Zwróć pusty strumień, gdy użytkownik nie jest zalogowany
    }

    _firestore
        .collection('event_urines')
        .where('petId', isEqualTo: petId)
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      _cachedUrineEvents = snapshot.docs
          .map((doc) => EventUrineModel.fromDocument(doc))
          .toList();

      _urineEventsController
          .add(_cachedUrineEvents); // Aktualizacja strumienia z cachem
    });

    return _urineEventsController.stream;
  }

  /// Dodaje nowy event urine do Firestore
  Future<void> addUrineEvent(EventUrineModel event) async {
    await _firestore
        .collection('event_urines')
        .doc(event.id)
        .set(event.toMap());

    // Aktualizacja cache natychmiast po dodaniu
    _cachedUrineEvents.add(event);
    _urineEventsController.add(_cachedUrineEvents); // Aktualizacja strumienia
  }

  /// Usuwa event urine z Firestore
  Future<void> deleteUrineEvent(String eventId) async {
    await _firestore.collection('event_urines').doc(eventId).delete();

    // Usuwanie eventu z cache'u i aktualizacja strumienia
    _cachedUrineEvents.removeWhere((event) => event.id == eventId);
    _urineEventsController.add(_cachedUrineEvents); // Aktualizacja strumienia
  }

  /// Zamyka kontroler strumienia podczas usuwania instancji
  void dispose() {
    _urineEventsController.close();
  }
}
