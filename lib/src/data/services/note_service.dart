import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/note_model.dart';

class NoteService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _notesController = StreamController<List<Note>>.broadcast();

  Stream<List<Note>> getNotes() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('notes')
        .snapshots()
        .listen((snapshot) {
      _notesController
          .add(snapshot.docs.map((doc) => Note.fromDocument(doc)).toList());
    });

    return _notesController.stream;
  }

  Stream<Note?> getNoteByIdStream(String noteId) {
    return Stream.fromFuture(getNoteById(noteId));
  }

  Future<Note?> getNoteById(String noteId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('notes')
        .doc(noteId)
        .get();

    return docSnapshot.exists ? Note.fromDocument(docSnapshot) : null;
  }

  Future<void> addNote(Note note) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  void dispose() {
    _notesController.close();
  }
}
