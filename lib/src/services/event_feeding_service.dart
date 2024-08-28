import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_feeding_model.dart';

class EventFeedingService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addFeeding(EventFeedingModel feeding) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_feedings')
        .doc(feeding.id)
        .set(feeding.toMap());
  }

  Future<void> updateFeeding(EventFeedingModel feeding) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_feedings')
        .doc(feeding.id)
        .update(feeding.toMap());
  }

  Future<void> deleteFeeding(String feedingId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_feedings')
        .doc(feedingId)
        .delete();
  }

  Future<List<EventFeedingModel>> getFeedings() async {
    final snapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_feedings')
        .get();
    return snapshot.docs
        .map((doc) => EventFeedingModel.fromDocument(doc))
        .toList();
  }

  Future<EventFeedingModel?> getFeedingById(String feedingId) async {
    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('event_feedings')
        .doc(feedingId)
        .get();
    return docSnapshot.exists
        ? EventFeedingModel.fromDocument(docSnapshot)
        : null;
  }
}
