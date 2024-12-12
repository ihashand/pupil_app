import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';
import 'package:pet_diary/src/providers/others_providers/friend_provider.dart';
import 'package:pet_diary/src/services/other_services/friend_service.dart';

final friendRequestsNotifierProvider =
    StateNotifierProvider<FriendRequestsNotifier, List<FriendRequest>>((ref) {
  return FriendRequestsNotifier(ref);
});

class FriendRequestsNotifier extends StateNotifier<List<FriendRequest>> {
  FriendRequestsNotifier(this.ref) : super([]) {
    loadFriendRequests();
  }

  final Ref ref;

  void loadFriendRequests() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      FirebaseFirestore.instance
          .collection('app_users')
          .doc(currentUserId)
          .collection('friend_requests')
          .snapshots()
          .listen((snapshot) {
        state = snapshot.docs
            .map((doc) => FriendRequest.fromDocument(doc))
            .toList();
      });
    }
  }

  void acceptFriendRequest(String fromUserId, String toUserId) async {
    await ref
        .read(friendServiceProvider)
        .acceptFriendRequest(fromUserId, toUserId);
    state = state.where((request) => request.fromUserId != fromUserId).toList();
  }

  void declineFriendRequest(String fromUserId, String toUserId) async {
    await ref
        .read(friendServiceProvider)
        .cancelFriendRequest(fromUserId, toUserId);
    state = state.where((request) => request.fromUserId != fromUserId).toList();
  }
}

final friendsNotifierProvider =
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
    await _friendService.addFriend(friend);
    state = [...state, friend];
  }

  Future<void> removeFriend(String friendId) async {
    await _friendService.removeFriend(friendId);
    state = state.where((friend) => friend.friendId != friendId).toList();
  }

  Future<void> sendFriendRequest(String toUserId) async {
    await _friendService.sendFriendRequest(toUserId);
  }

  Future<void> cancelFriendRequest(String fromUserId, String toUserId) async {
    await _friendService.cancelFriendRequest(fromUserId, toUserId);
  }

  Future<void> acceptFriendRequest(String fromUserId, String toUserId) async {
    await _friendService.acceptFriendRequest(fromUserId, toUserId);
  }
}
