import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';

class EventNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for broadcasting note events stream
  final StreamController<List<EventNoteModel>> _notesController =
      StreamController<List<EventNoteModel>>.broadcast();

  // Cache for storing notes
  List<EventNoteModel>? _cachedNotes;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream to get notes for a specific pet.
  Stream<List<EventNoteModel>> getNotes(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedNotes != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _notesController.add(_cachedNotes!);
      } else {
        final subscription = _firestore
            .collection('event_notes')
            .where('userId', isEqualTo: _currentUser.uid)
            .where('petId', isEqualTo: petId)
            .snapshots()
            .listen((snapshot) {
          final notes = snapshot.docs
              .map((doc) => EventNoteModel.fromDocument(doc))
              .toList();
          _cachedNotes = notes;
          _lastFetchTime = DateTime.now();
          _notesController.add(notes);
        }, onError: (error) {
          debugPrint('Error listening to notes stream: $error');
          _notesController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _notesController.stream;
    } catch (e) {
      debugPrint('Error in getNotes: $e');
      return Stream.error(e);
    }
  }

  /// Stream to get a single note by ID.
  Stream<EventNoteModel?> getNoteByIdStream(String noteId) {
    return Stream.fromFuture(getNoteById(noteId));
  }

  /// Fetches a single note by ID.
  Future<EventNoteModel?> getNoteById(String noteId) async {
    if (_currentUser == null) {
      return null;
    }

    try {
      final docSnapshot =
          await _firestore.collection('event_notes').doc(noteId).get();

      return docSnapshot.exists
          ? EventNoteModel.fromDocument(docSnapshot)
          : null;
    } catch (e) {
      debugPrint('Error fetching note by ID: $e');
      return null;
    }
  }

  /// Adds a new note event.
  Future<void> addNote(EventNoteModel note) async {
    try {
      await _firestore.collection('event_notes').doc(note.id).set(note.toMap());
      _cachedNotes = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding note event: $e');
    }
  }

  /// Updates an existing note event.
  Future<void> updateNote(EventNoteModel note) async {
    try {
      await _firestore
          .collection('event_notes')
          .doc(note.id)
          .update(note.toMap());
      _cachedNotes = null; // Invalidate cache after updating
    } catch (e) {
      debugPrint('Error updating note event: $e');
    }
  }

  /// Deletes a note event by ID.
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('event_notes').doc(noteId).delete();
      _cachedNotes = null; // Invalidate cache after deleting
    } catch (e) {
      debugPrint('Error deleting note event: $e');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _notesController.close();
  }
}
