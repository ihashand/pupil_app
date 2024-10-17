import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';

class EventNoteService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _notesController = StreamController<List<EventNoteModel>>.broadcast();

  Stream<List<EventNoteModel>> getNotes(String petId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_notes')
        .snapshots()
        .listen((snapshot) {
      _notesController.add(snapshot.docs
          .map((doc) => EventNoteModel.fromDocument(doc))
          .toList());
    });

    return _notesController.stream;
  }

  Stream<EventNoteModel?> getNoteByIdStream(String noteId, String petId) {
    return Stream.fromFuture(getNoteById(noteId, petId));
  }

  Future<EventNoteModel?> getNoteById(String noteId, String petId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_notes')
        .doc(noteId)
        .get();

    return docSnapshot.exists ? EventNoteModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addNote(EventNoteModel note, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_notes')
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> updateNote(EventNoteModel note, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String noteId, String petId) async {
    await _firestore
        .collection('app_users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId)
        .collection('event_notes')
        .doc(noteId)
        .delete();
  }

  void dispose() {
    _notesController.close();
  }
}
