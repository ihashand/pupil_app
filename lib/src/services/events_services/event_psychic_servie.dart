import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_issue_model.dart';

class EventIssueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting issue events stream
  final StreamController<List<EventIssueModel>> _issueEventsController =
      StreamController<List<EventIssueModel>>.broadcast();

  // Cache for fetched event issues, to optimize performance
  List<EventIssueModel>? _cachedIssues = [];

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get real-time updates of user's event issues.
  Stream<List<EventIssueModel>> getIssuesStream() {
    if (_currentUser == null) {
      return Stream.value(
          []); // Return empty stream if user is not authenticated
    }

    try {
      final subscription = _firestore
          .collection('event_issues')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        _cachedIssues = snapshot.docs
            .map((doc) => EventIssueModel.fromDocument(doc))
            .toList();
        _issueEventsController.add(_cachedIssues!);
      }, onError: (error) {
        debugPrint('Error listening to issues stream: $error');
        _issueEventsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _issueEventsController.stream;
    } catch (e) {
      debugPrint('Error in getIssuesStream: $e');
      return Stream.error(e);
    }
  }

  /// Adds a new event issue to Firestore
  Future<void> addIssue(EventIssueModel issue) async {
    try {
      await _firestore
          .collection('event_issues')
          .doc(issue.id)
          .set(issue.toMap());

      _cachedIssues ??= [];
      _cachedIssues!.add(issue); // Update cache immediately after adding
      _issueEventsController.add(_cachedIssues!); // Update the stream
    } catch (e) {
      debugPrint('Error adding issue: $e');
    }
  }

  /// Deletes an event issue from Firestore
  Future<void> deleteIssue(String issueId) async {
    try {
      await _firestore.collection('event_issues').doc(issueId).delete();
      _cachedIssues
          ?.removeWhere((issue) => issue.id == issueId); // Update cache
      _issueEventsController.add(_cachedIssues!); // Update the stream
    } catch (e) {
      debugPrint('Error deleting issue: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _issueEventsController.close();
  }
}
