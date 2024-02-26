import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/weight_repository.dart';

final weightRepositoryProvider = FutureProvider<WeightRepository>((_) async {
  return await WeightRepository.create();
});

final weightNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final weightControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final weightDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
