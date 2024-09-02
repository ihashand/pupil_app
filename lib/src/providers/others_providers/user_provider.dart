import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/local_user_service.dart';

final localUserServiceProvider = Provider((ref) {
  return LocalUserService();
});
