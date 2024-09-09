import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/services/other_services/local_user_service.dart';

final localUserServiceProvider = Provider((ref) {
  return LocalUserService();
});
