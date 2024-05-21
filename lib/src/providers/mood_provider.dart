import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/mood_model.dart';
import 'package:pet_diary/src/services/mood_service.dart';

final moodServiceProvider = Provider((ref) {
  return MoodService();
});

final moodsProvider = StreamProvider<List<Mood>>((ref) {
  return ref.watch(moodServiceProvider).getMoodsStream();
});
