import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/note_model.dart';

class NoteRepository {
  late Box<Note> _hive;
  late List<Note> _box;

  NoteRepository._create();

  static Future<NoteRepository> create() async {
    final component = NoteRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Note>('noteBox');
    _box = _hive.values.toList();
  }

  List<Note> getNotes() {
    return _box;
  }

  Future<void> addNote(Note note) async {
    await _hive.put(note.id, note);
    await _init();
  }

  Future<void> updateNote(Note note) async {
    await _hive.put(note.id, note);
  }

  Future<void> deleteNote(int index) async {
    await _hive.deleteAt(index);
    await _init();
  }

  Note? getNoteById(String noteId) {
    return _hive.get(noteId);
  }
}
