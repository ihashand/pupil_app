import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/note_service.dart';

final noteServiceProvider = Provider((ref) {
  return NoteService();
});
