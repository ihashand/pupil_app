import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProvider extends StateNotifier<User?> {
  UserProvider() : super(FirebaseAuth.instance.currentUser);

  void updateUser(User? newUser) {
    state = newUser;
  }
}

final userProvider = StateNotifierProvider<UserProvider, User?>((ref) {
  return UserProvider();
});
