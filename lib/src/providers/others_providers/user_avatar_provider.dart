import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userAvatarProvider = StateProvider<String>((ref) {
  return FirebaseAuth.instance.currentUser?.photoURL ??
      'assets/images/beagle.png';
});
