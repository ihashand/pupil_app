import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';
import 'package:pet_diary/src/services/events_services/event_note_service.dart';

final eventNoteServiceProvider = Provider((ref) {
  return EventNoteService();
});

final eventNotesStreamProvider = StreamProvider.autoDispose
    .family<List<EventNoteModel>, String>((ref, petId) {
  return ref.read(eventNoteServiceProvider).getNotes(petId);
});

final eventNoteByIdProvider =
    StreamProvider.autoDispose.family<EventNoteModel?, String>((ref, noteId) {
  return ref.read(eventNoteServiceProvider).getNoteByIdStream(noteId);
});
