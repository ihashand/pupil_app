import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/services/other_services/friend_service.dart';

final friendServiceProvider = Provider((ref) {
  return FriendService();
});

final friendsStreamProvider = StreamProvider<List<Friend>>((ref) {
  return ref.watch(friendServiceProvider).getFriendsStream();
});

final friendRequestsStreamProvider = StreamProvider<List<FriendRequest>>((ref) {
  return ref.watch(friendServiceProvider).getFriendRequestsStream();
});

final friendPetsProvider =
    FutureProvider.family<List<Pet>, String>((ref, friendId) {
  return ref.read(petServiceProvider).getPetsByUserId(friendId);
});
