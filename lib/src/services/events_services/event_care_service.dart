import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';

class EventCareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controller to manage cache and broadcasting stream data for real-time updates
  final StreamController<List<EventCareModel>> _caresController =
      StreamController<List<EventCareModel>>.broadcast();

  // Cache for fetched event cares, to optimize performance
  List<EventCareModel> _cachedCares = []; // Initialize as an empty list

  /// Stream to get real-time updates of user's care events.
  Stream<List<EventCareModel>> getCaresStream() {
    // Listen to Firestore collection changes and update cache & controller
    _firestore.collection('event_cares').snapshots().listen((snapshot) {
      _cachedCares =
          snapshot.docs.map((doc) => EventCareModel.fromDocument(doc)).toList();

      // Add only if _cachedCares is not empty to avoid null issues
      _caresController.add(_cachedCares);
    });

    return _caresController.stream;
  }

  /// Adds a new care event to Firestore.
  Future<void> addCare(EventCareModel care) async {
    await _firestore.collection('event_cares').doc(care.id).set(care.toMap());

    // Update cache immediately after adding
    _cachedCares.add(care);
    _caresController.add(_cachedCares); // Update the stream
  }

  /// Deletes a care event from Firestore.
  Future<void> deleteCare(String careId) async {
    await _firestore.collection('event_cares').doc(careId).delete();

    // Remove the care from the cache and update the stream
    _cachedCares.removeWhere((care) => care.id == careId);
    _caresController.add(_cachedCares); // Update the stream
  }

  /// Clears stream controller on disposal
  void dispose() {
    _caresController.close();
  }
}
