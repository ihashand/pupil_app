import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/stomach_model.dart';
import 'package:pet_diary/src/services/stomach_service.dart';

final stomachServiceProvider = Provider((ref) {
  return StomachService();
});

final stomachProvider = StreamProvider<List<Stomach>>((ref) {
  return ref.watch(stomachServiceProvider).getStomachStream();
});
