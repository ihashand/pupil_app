import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';

class EventStoolService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Kontroler zarządzający strumieniem wydarzeń
  final StreamController<List<EventStoolModel>> _stoolEventsController =
      StreamController<List<EventStoolModel>>.broadcast();

  // Pamięć podręczna dla wydarzeń typu "stool" w celu optymalizacji wydajności
  List<EventStoolModel> _cachedStoolEvents = [];

  /// Pobiera strumień wydarzeń typu "stool" dla zalogowanego użytkownika
  Stream<List<EventStoolModel>> getStoolEventsStream() {
    if (_currentUser == null) {
      return Stream.value(
          []); // Pusty strumień, jeśli użytkownik nie jest zalogowany
    }

    // Nasłuchiwanie zmian w Firestore i aktualizacja pamięci podręcznej oraz strumienia
    _firestore
        .collection('event_stools')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      _cachedStoolEvents = snapshot.docs
          .map((doc) => EventStoolModel.fromDocument(doc))
          .toList();
      _stoolEventsController.add(_cachedStoolEvents); // Aktualizacja strumienia
    });

    return _stoolEventsController.stream;
  }

  /// Dodaje nowe wydarzenie typu "stool" do Firestore i pamięci podręcznej
  Future<void> addStoolEvent(EventStoolModel event) async {
    await _firestore
        .collection('event_stools')
        .doc(event.id)
        .set(event.toMap());

    // Aktualizacja pamięci podręcznej natychmiast po dodaniu
    _cachedStoolEvents.add(event);
    _stoolEventsController.add(_cachedStoolEvents); // Aktualizacja strumienia
  }

  /// Usuwa wydarzenie typu "stool" z Firestore oraz z pamięci podręcznej
  Future<void> deleteStoolEvent(String eventId) async {
    await _firestore.collection('event_stools').doc(eventId).delete();

    // Usunięcie wydarzenia z pamięci podręcznej i aktualizacja strumienia
    _cachedStoolEvents.removeWhere((event) => event.id == eventId);
    _stoolEventsController.add(_cachedStoolEvents); // Aktualizacja strumienia
  }

  /// Czyszczenie zasobów kontrolera strumienia przy zakończeniu pracy serwisu
  void dispose() {
    _stoolEventsController.close();
  }
}
