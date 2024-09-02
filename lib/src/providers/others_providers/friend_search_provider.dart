import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/app_user_model.dart';

final friendsSearchProvider =
    StateNotifierProvider<FriendsSearchNotifier, List<AppUserModel>>((ref) {
  return FriendsSearchNotifier();
});

class FriendsSearchNotifier extends StateNotifier<List<AppUserModel>> {
  FriendsSearchNotifier() : super([]);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> searchUserByEmail(String email) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserEmail != null &&
        email.toLowerCase() == currentUserEmail.toLowerCase()) {
      state = [];
      return;
    }

    try {
      final result = await _firestore
          .collection('app_users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (result.docs.isNotEmpty) {
        final userDoc = result.docs.first;
        final userProfile = AppUserModel.fromDocument(userDoc);

        final friendRequests = await _firestore
            .collection('app_users')
            .doc(currentUserId)
            .collection('friend_requests')
            .where('toUserId', isEqualTo: userProfile.id)
            .get();

        final friends = await _firestore
            .collection('friends')
            .where('userId', isEqualTo: currentUserId)
            .where('friendId', isEqualTo: userProfile.id)
            .get();

        if (friendRequests.docs.isEmpty && friends.docs.isEmpty) {
          state = [userProfile];
        } else {
          state = [];
        }
      } else {
        state = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching user by email: $e');
      }
      state = [];
    }
  }
}
