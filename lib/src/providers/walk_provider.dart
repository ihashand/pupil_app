import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/walk_repository.dart';

final walkRepositoryProvider = FutureProvider<WalkRepository>((_) async {
  return await WalkRepository.create();
});

final walkNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final walkControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final walkDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
