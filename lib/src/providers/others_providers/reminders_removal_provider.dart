import 'package:flutter_riverpod/flutter_riverpod.dart';

final autoRemoveEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

final autoRemoveHoursProvider = StateProvider<int>((ref) {
  return 0; // Default to 0 hours
});

final autoRemoveMinutesProvider = StateProvider<int>((ref) {
  return 30; // Default to 30 minutes
});
