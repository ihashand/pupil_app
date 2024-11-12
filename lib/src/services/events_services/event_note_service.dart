import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';

class EventNoteService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _notesController = StreamController<List<EventNoteModel>>.broadcast();
  List<EventNoteModel>? _cachedNotes;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  Stream<List<EventNoteModel>> getNotes(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    // Fetch notes from Firestore only if cache is expired
    if (_cachedNotes != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      _notesController.add(_cachedNotes!);
    } else {
      _firestore
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
      });
    }

    return _notesController.stream;
  }

  Stream<EventNoteModel?> getNoteByIdStream(String noteId) {
    return Stream.fromFuture(getNoteById(noteId));
  }

  Future<EventNoteModel?> getNoteById(String noteId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot =
        await _firestore.collection('event_notes').doc(noteId).get();

    return docSnapshot.exists ? EventNoteModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addNote(EventNoteModel note) async {
    await _firestore.collection('event_notes').doc(note.id).set(note.toMap());
    _cachedNotes = null;
  }

  Future<void> updateNote(EventNoteModel note) async {
    await _firestore
        .collection('event_notes')
        .doc(note.id)
        .update(note.toMap());
    _cachedNotes = null;
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('event_notes').doc(noteId).delete();
    _cachedNotes = null;
  }

  void dispose() {
    _notesController.close();
  }
}
