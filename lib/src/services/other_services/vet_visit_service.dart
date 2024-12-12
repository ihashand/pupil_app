import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_diary/src/models/others/vet_visit_model.dart';

class VetVisitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // StreamController for managing vet visits stream
  final StreamController<List<VetVisitModel>> _vetVisitsController =
      StreamController<List<VetVisitModel>>.broadcast();

  // Cache for fetched vet visits
  List<VetVisitModel>? _cachedVetVisits;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Add a new vet visit to Firestore.
  Future<void> addVetVisit(VetVisitModel visit) async {
    try {
      await _firestore
          .collection('vet_visits')
          .doc(visit.id)
          .set(visit.toMap());
      _cachedVetVisits = null; // Invalidate cache
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
      _cachedVetVisits = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error updating vet visit: $e');
      throw Exception('Failed to update vet visit');
    }
  }

  /// Delete a vet visit from Firestore.
  Future<void> deleteVetVisit(String visitId) async {
    try {
      await _firestore.collection('vet_visits').doc(visitId).delete();
      _cachedVetVisits = null; // Invalidate cache
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

  /// Fetch all vet visits as a one-time operation with caching.
  Future<List<VetVisitModel>> getVetVisits() async {
    try {
      if (_cachedVetVisits != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedVetVisits!;
      }

      final querySnapshot = await _firestore.collection('vet_visits').get();
      _cachedVetVisits = querySnapshot.docs
          .map((doc) => VetVisitModel.fromDocument(doc))
          .toList();
      _lastFetchTime = DateTime.now();

      return _cachedVetVisits!;
    } catch (e) {
      debugPrint('Error fetching vet visits: $e');
      throw Exception('Failed to fetch vet visits');
    }
  }

  /// Stream of vet visits for real-time updates.
  Stream<List<VetVisitModel>> getVetVisitsStream() {
    try {
      final subscription =
          _firestore.collection('vet_visits').snapshots().listen(
        (snapshot) {
          final vetVisits = snapshot.docs
              .map((doc) => VetVisitModel.fromDocument(doc))
              .toList();
          _cachedVetVisits = vetVisits;
          _vetVisitsController.add(vetVisits);
        },
        onError: (error) {
          debugPrint('Error streaming vet visits: $error');
          _vetVisitsController.addError(error);
        },
      );

      _subscriptions.add(subscription);
      return _vetVisitsController.stream;
    } catch (e) {
      debugPrint('Error in getVetVisitsStream: $e');
      return Stream.error(e);
    }
  }

  /// Dispose of resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _vetVisitsController.close();
  }
}
