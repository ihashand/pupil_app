import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';
import 'package:pet_diary/src/services/friend_service.dart';

final friendServiceProvider = Provider((ref) {
  return FriendService();
});

final friendsStreamProvider = StreamProvider<List<Friend>>((ref) {
  return ref.watch(friendServiceProvider).getFriendsStream();
});

final friendRequestsStreamProvider = StreamProvider<List<FriendRequest>>((ref) {
  return ref.watch(friendServiceProvider).getFriendRequestsStream();
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
