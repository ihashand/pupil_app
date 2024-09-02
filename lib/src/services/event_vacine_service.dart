import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';

class VaccineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _vaccineEventsController =
      StreamController<List<EventVaccineModel>>.broadcast();

  Stream<List<EventVaccineModel>> getVaccineStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('eventVaccines')
        .snapshots()
        .listen((snapshot) {
      _vaccineEventsController.add(snapshot.docs
          .map((doc) => EventVaccineModel.fromDocument(doc))
          .toList());
    });

    return _vaccineEventsController.stream;
  }

  Future<void> addVaccine(EventVaccineModel vaccine) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('eventVaccines')
        .doc(vaccine.id)
        .set(vaccine.toMap());
  }

  Future<void> deleteVaccine(String vaccineId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('eventVaccines')
        .doc(vaccineId)
        .delete();
  }

  void dispose() {
    _vaccineEventsController.close();
  }
}
