import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import '../data/services/weight_service.dart';

final weightServiceProvider = Provider((ref) {
  return WeightService();
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

final weightsProvider = StreamProvider<List<Weight?>>((ref) {
  return WeightService().getWeightsStream();
});
