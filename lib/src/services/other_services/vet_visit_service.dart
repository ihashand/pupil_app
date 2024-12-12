import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/vet_visit_model.dart';

class VetVisitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<VetVisitModel>> _vetVisitsController =
      StreamController<List<VetVisitModel>>.broadcast();

  /// Add a new vet visit to Firestore.
  Future<void> addVetVisit(VetVisitModel visit) async {
    try {
      await _firestore
          .collection('vet_visits')
          .doc(visit.id)
          .set(visit.toMap());
    } catch (e) {
      debugPrint('Error adding vet visit: $e');
      throw Exception('Failed to add vet visit');
    }
  }

  /// Update an existing vet visit in Firestore.
  Future<void> updateVetVisit(VetVisitModel visit) async {
    try {
      await _firestore
          .collection('vet_visits')
          .doc(visit.id)
          .update(visit.toMap());
    } catch (e) {
      debugPrint('Error updating vet visit: $e');
      throw Exception('Failed to update vet visit');
    }
  }

  /// Delete a vet visit from Firestore.
  Future<void> deleteVetVisit(String visitId) async {
    try {
      await _firestore.collection('vet_visits').doc(visitId).delete();
    } catch (e) {
      debugPrint('Error deleting vet visit: $e');
      throw Exception('Failed to delete vet visit');
    }
  }

  /// Fetch a single vet visit by its ID.
  Future<VetVisitModel?> getVetVisitById(String visitId) async {
    try {
      final docSnapshot =
          await _firestore.collection('vet_visits').doc(visitId).get();
      return docSnapshot.exists
          ? VetVisitModel.fromDocument(docSnapshot)
          : null;
    } catch (e) {
      debugPrint('Error fetching vet visit by ID: $e');
      throw Exception('Failed to fetch vet visit by ID');
    }
  }

  /// Fetch all vet visits as a one-time operation.
  Future<List<VetVisitModel>> getVetVisits() async {
    try {
      final querySnapshot = await _firestore.collection('vet_visits').get();
      return querySnapshot.docs
          .map((doc) => VetVisitModel.fromDocument(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching vet visits: $e');
      throw Exception('Failed to fetch vet visits');
    }
  }

  /// Stream of vet visits for real-time updates.
  Stream<List<VetVisitModel>> getVetVisitsStream() {
    _firestore.collection('vet_visits').snapshots().listen((snapshot) {
      final vetVisits =
          snapshot.docs.map((doc) => VetVisitModel.fromDocument(doc)).toList();
      _vetVisitsController.add(vetVisits);
    }, onError: (error) {
      debugPrint('Error streaming vet visits: $error');
      _vetVisitsController.addError(error);
    });

    return _vetVisitsController.stream;
  }

  /// Dispose of the stream controller to free up resources.
  void dispose() {
    _vetVisitsController.close();
  }
}
