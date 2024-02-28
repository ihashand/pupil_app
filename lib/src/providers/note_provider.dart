import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/note_repository.dart';

final noteRepositoryProvider = FutureProvider<NoteRepository>((_) async {
  return await NoteRepository.create();
});

final noteNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final noteControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final noteDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
