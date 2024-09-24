import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';
import 'package:pet_diary/src/services/other_services/friend_service.dart';

final friendServiceProvider = Provider((ref) {
  return FriendService();
});

final friendsProvider =
    StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  return FriendsNotifier(ref);
});

final friendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('app_users')
      .doc(currentUserId)
      .collection('friend_requests')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => FriendRequest.fromDocument(doc)).toList());
});

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier(this.ref) : super([]);

  final Ref ref;
  final _friendService = FriendService();

  Future<void> loadFriends() async {
    state = await _friendService.getFriendsStream().first;
  }

  Future<void> addFriend(Friend friend) async {
    await _friendService.addFriend(friend, friend.id);
    state = [...state, friend];
  }

  Future<void> removeFriend(String friendId) async {
    await _friendService.removeFriend(friendId);
    state = state.where((friend) => friend.friendId != friendId).toList();
  }

  Future<void> sendFriendRequest(String toUserId) async {
    await _friendService.sendFriendRequest(toUserId);
  }

  Future<void> cancelFriendRequest(String toUserId) async {
    await _friendService.cancelFriendRequest(toUserId);
  }

  Future<void> acceptFriendRequest(String fromUserId, String toUserId) async {
    await _friendService.acceptFriendRequest(fromUserId, toUserId);
  }

  Future<void> declineFriendRequest(String fromUserId, String toUserId) async {
    await _friendService.declineFriendRequest(fromUserId, toUserId);
  }
}
