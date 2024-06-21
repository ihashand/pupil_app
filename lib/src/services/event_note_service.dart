import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_note_model.dart';

class EventNoteService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _notesController = StreamController<List<EventNoteModel>>.broadcast();

  Stream<List<EventNoteModel>> getNotes() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_notes')
        .snapshots()
        .listen((snapshot) {
      _notesController.add(snapshot.docs
          .map((doc) => EventNoteModel.fromDocument(doc))
          .toList());
    });

    return _notesController.stream;
  }

  Stream<EventNoteModel?> getNoteByIdStream(String noteId) {
    return Stream.fromFuture(getNoteById(noteId));
  }

  Future<EventNoteModel?> getNoteById(String noteId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_notes')
        .doc(noteId)
        .get();

    return docSnapshot.exists ? EventNoteModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addNote(EventNoteModel note) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_notes')
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> updateNote(EventNoteModel note) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_notes')
        .doc(noteId)
        .delete();
  }

  void dispose() {
    _notesController.close();
  }
}
