import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_issue_model.dart';

class EventIssueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _issueEventsController =
      StreamController<List<EventIssueModel>>.broadcast();

  // Cache for fetched event issues, to optimize performance
  List<EventIssueModel>? _cachedIssues = []; // Initialize with an empty list

  /// Stream to get real-time updates of user's event issues.
  Stream<List<EventIssueModel>> getIssuesStream() {
    if (_currentUser == null) {
      return Stream.value(
          []); // Return empty stream if user is not authenticated
    }

    // Listen to Firestore collection changes, and update cache & controller
    _firestore
        .collection('event_issues')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      _cachedIssues = snapshot.docs
          .map((doc) => EventIssueModel.fromDocument(doc))
          .toList();
      _issueEventsController.add(_cachedIssues!);
    });

    return _issueEventsController.stream;
  }

  /// Adds a new event issue to Firestore
  Future<void> addIssue(EventIssueModel issue) async {
    await _firestore
        .collection('event_issues')
        .doc(issue.id)
        .set(issue.toMap());

    // Ensure _cachedIssues is initialized
    _cachedIssues ??= [];

    _cachedIssues!.add(issue); // Update cache immediately after adding
    _issueEventsController.add(_cachedIssues!); // Update the stream
  }

  /// Deletes an event issue from Firestore
  Future<void> deleteIssue(String issueId) async {
    await _firestore.collection('event_issues').doc(issueId).delete();
    _cachedIssues?.removeWhere((issue) => issue.id == issueId); // Update cache
    _issueEventsController.add(_cachedIssues!); // Update the stream
  }

  /// Clears stream controller on disposal
  void dispose() {
    _issueEventsController.close();
  }
}
