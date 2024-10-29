import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_service_event_model.dart';

class EventServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _servicesEventController =
      StreamController<List<EventServiceModel>>.broadcast();

  Stream<List<EventServiceModel>> getServicesEventStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore.collection('event_services').snapshots().listen((snapshot) {
      _servicesEventController.add(
        snapshot.docs
            .map((doc) => EventServiceModel.fromDocument(doc))
            .toList(),
      );
    });

    return _servicesEventController.stream;
  }

  Future<void> addServiceEvent(EventServiceModel service) async {
    await _firestore
        .collection('event_services')
        .doc(service.id)
        .set(service.toMap());
  }

  Future<void> deleteServiceEvent(String serviceId) async {
    await _firestore.collection('event_services').doc(serviceId).delete();
  }

  void dispose() {
    _servicesEventController.close();
  }
}
