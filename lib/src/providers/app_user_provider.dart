import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/app_user_model.dart';
import 'package:pet_diary/src/services/app_user_service.dart';

final appUserServiceProvider = Provider((ref) {
  return AppUserService();
});

final appUserProvider = StreamProvider<List<AppUserModel>>((ref) {
  return ref.watch(appUserServiceProvider).getAppUsersStream();
});

final appUserDetailsProvider =
    FutureProvider.family<AppUserModel, String>((ref, userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('app_users')
      .doc(userId)
      .get();
  if (doc.exists) {
    return AppUserModel.fromDocument(doc);
  } else {
    throw Exception('User not found');
  }
});
