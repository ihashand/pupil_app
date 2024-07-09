import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/walk_service.dart';

final walkServiceProvider = Provider((ref) {
  return WalkService();
});
