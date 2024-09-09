import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_note_service.dart';

final eventNoteServiceProvider = Provider((ref) {
  return EventNoteService();
});
