import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/other_services/local_user_service.dart';

final localUserServiceProvider = Provider((ref) {
  return LocalUserService();
});

final userIdProvider = StateProvider<String?>((ref) => null);
