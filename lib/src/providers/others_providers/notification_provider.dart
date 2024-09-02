import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

final notificationTimeProvider = StateProvider<TimeOfDay>((ref) {
  return const TimeOfDay(hour: 10, minute: 0);
});
