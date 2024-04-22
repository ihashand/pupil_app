import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/walk_service.dart';

final walkServiceProvider = Provider((ref) {
  return WalkService();
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
